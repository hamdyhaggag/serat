import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:serat/Business_Logic/Cubit/reciters_cubit.dart';
import 'package:serat/Business_Logic/Models/reciter_model.dart';
import 'package:serat/imports.dart';
import 'package:flutter/foundation.dart';
import '../../services/reciter_notification_service.dart';

class RecitersScreen extends StatefulWidget {
  const RecitersScreen({super.key});

  @override
  State<RecitersScreen> createState() => _RecitersScreenState();
}

class _RecitersScreenState extends State<RecitersScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  List<Reciter> _filteredReciters = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ReciterNotificationService _notificationService =
      ReciterNotificationService();
  bool _isPlaying = false;
  bool _isInitialized = false;
  bool _isOfflineMode = false;
  String _currentReciterName = '';
  String _currentSurahName = '';
  bool _autoPlayNextSura = false;
  int? _currentSurahNumber;
  Moshaf? _currentMoshaf;
  Reciter? _currentReciter;
  ValueNotifier<int>? _currentSurahNotifier;

  @override
  void initState() {
    super.initState();
    _initializeAudio();
    _initializeNotificationService();
    _loadReciters();
    _setupAnimation();
    _setupSearchListener();
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);
    _animationController.forward();
  }

  void _setupSearchListener() {
    _searchController.addListener(() {
      if (_searchController.text.isNotEmpty) {
        _filterReciters(_searchController.text);
      }
    });
  }

  Future<void> _initializeAudio() async {
    try {
      _setupAudioListeners();
      await _audioPlayer.setVolume(1.0);
      setState(() => _isInitialized = true);
    } catch (e) {
      _showErrorSnackBar('لم يتم تهيئة مشغل الصوت بشكل صحيح');
    }
  }

  void _setupAudioListeners() {
    _audioPlayer.onLog.listen((msg) {
      debugPrint('Audio player error: $msg');
      if (mounted) _showErrorSnackBar('حدث خطأ أثناء تشغيل التلاوة');
    });

    _audioPlayer.onPlayerComplete.listen((_) async {
      if (mounted) setState(() => _isPlaying = false);
      if (_autoPlayNextSura &&
          _currentSurahNumber != null &&
          _currentMoshaf != null &&
          _currentReciter != null) {
        final surahList = _currentMoshaf!.surahList
            .split(',')
            .map((e) => int.tryParse(e.trim()))
            .whereType<int>()
            .toList();
        final idx = surahList.indexOf(_currentSurahNumber!);
        if (idx != -1 && idx + 1 < surahList.length) {
          final nextSurah = surahList[idx + 1];
          final audioUrl = _buildAudioUrl(_currentMoshaf!.server, nextSurah);
          final surahName = _getSurahName(nextSurah);
          setState(() {
            _currentSurahNumber = nextSurah;
            _currentSurahName = surahName;
          });
          _currentSurahNotifier?.value = nextSurah;
          try {
            await _playAudio(audioUrl, _currentReciter!.name, surahName,
                updateState: false);
          } catch (e) {
            // No need to print error here, as it's handled in _playAudio
          }
        }
      }
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _isPlaying = state == PlayerState.playing);
    });
  }

  Future<void> _initializeNotificationService() async {
    await _notificationService.initialize();
    _notificationService.onStop = _stopAudio;
  }

  Future<void> _playAudio(String url, String reciterName, String surahName,
      {bool updateState = true}) async {
    try {
      if (_isPlaying) {
        await _stopAudio();
      }

      await _audioPlayer.setSourceUrl(url);
      await _audioPlayer.resume();

      if (updateState) {
        setState(() {
          _isPlaying = true;
          _currentReciterName = reciterName;
          _currentSurahName = surahName;
        });
      }

      await _notificationService.showReciterNotification(
        reciterName: reciterName,
        surahName: surahName,
        isPlaying: true,
      );
    } catch (e) {
      debugPrint('Error playing audio: $e');
      _showErrorSnackBar('حدث خطأ أثناء تشغيل التلاوة');
    }
  }

  Future<void> _pauseAudio() async {
    try {
      await _audioPlayer.pause();
      setState(() => _isPlaying = false);

      await _notificationService.showReciterNotification(
        reciterName: _currentReciterName,
        surahName: _currentSurahName,
        isPlaying: false,
      );
    } catch (e) {
      _showErrorSnackBar('حدث خطأ أثناء إيقاف التلاوة مؤقتاً');
    }
  }

  Future<void> _resumeAudio() async {
    try {
      await _audioPlayer.resume();
      setState(() => _isPlaying = true);

      await _notificationService.showReciterNotification(
        reciterName: _currentReciterName,
        surahName: _currentSurahName,
        isPlaying: true,
      );
    } catch (e) {
      _showErrorSnackBar('حدث خطأ أثناء استئناف التلاوة');
    }
  }

  Future<void> _stopAudio() async {
    try {
      if (!_isPlaying) return;

      await _audioPlayer.stop();
      setState(() {
        _isPlaying = false;
        _currentReciterName = '';
        _currentSurahName = '';
      });

      await _notificationService.removeNotification();
    } catch (e) {
      debugPrint('Error stopping audio: $e');
      _showErrorSnackBar('حدث خطأ أثناء إيقاف التلاوة');
    }
  }

  void _loadReciters() {
    try {
      RecitersCubit.get(context).getReciters().then((_) {
        setState(() => _isOfflineMode = false);
        _filterReciters(_searchController.text);
      }).catchError((_) {
        setState(() => _isOfflineMode = true);
        _showErrorSnackBar('حدث خطأ أثناء تحميل بيانات القراء');
      });
    } catch (e) {
      setState(() => _isOfflineMode = true);
      _showErrorSnackBar('حدث خطأ أثناء تحميل بيانات القراء');
    }
  }

  void _filterReciters(String query) {
    final cubit = RecitersCubit.get(context);
    if (cubit.recitersModel == null) return;

    setState(() {
      _filteredReciters = query.isEmpty
          ? cubit.recitersModel!.reciters
          : cubit.recitersModel!.reciters
              .where(
                (reciter) =>
                    reciter.name.toLowerCase().contains(
                          query.toLowerCase(),
                        ) ||
                    reciter.letter.toLowerCase().contains(
                          query.toLowerCase(),
                        ),
              )
              .toList();
    });
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AppText(message, color: Colors.white),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xff1F1F1F) : Colors.white,
      appBar: _buildAppBar(isDarkMode),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildSearchBar(isDarkMode),
            Expanded(child: _buildRecitersList(isDarkMode)),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDarkMode) {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AppText(
            'القراء',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          if (_isOfflineMode) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_off, color: Colors.orange, size: 16),
                  SizedBox(width: 4),
                  AppText(
                    'وضع عدم الاتصال',
                    fontSize: 12,
                    color: Colors.orange,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      centerTitle: true,
      backgroundColor:
          isDarkMode ? const Color(0xff2F2F2F) : AppColors.primaryColor,
      elevation: 0,
      shape: const Border(),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [const Color(0xff2F2F2F), const Color(0xff1F1F1F)]
                : [
                    AppColors.primaryColor,
                    const Color.fromRGBO(0, 150, 136, 0.8),
                  ],
          ),
        ),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: isDarkMode
              ? const Color.fromRGBO(255, 255, 255, 0.7)
              : Colors.white,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            setState(() => _isOfflineMode = false);
            RecitersCubit.get(context).getReciters(forceRefresh: true);
          },
        ),
      ],
    );
  }

  Widget _buildSearchBar(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xff2F2F2F) : AppColors.primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: _SearchBar(
        controller: _searchController,
        isDarkMode: isDarkMode,
        onChanged: _filterReciters,
      ),
    );
  }

  Widget _buildRecitersList(bool isDarkMode) {
    return BlocBuilder<RecitersCubit, RecitersState>(
      builder: (context, state) {
        if (state is RecitersLoading && !_isOfflineMode) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is RecitersError && !_isOfflineMode) {
          return _ErrorView(
            error: RecitersCubit.get(context).error ?? 'حدث خطأ غير معروف',
            onRetry: () {
              setState(() => _isOfflineMode = false);
              _loadReciters();
            },
          );
        }

        final cubit = RecitersCubit.get(context);
        if (cubit.recitersModel?.reciters.isEmpty ?? true) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppText('لا يوجد قراء', fontSize: 16),
                if (_isOfflineMode) ...[
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() => _isOfflineMode = false);
                      RecitersCubit.get(
                        context,
                      ).getReciters(forceRefresh: true);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const AppText('إعادة المحاولة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _filteredReciters.length,
          itemBuilder: (context, index) {
            return _ReciterCard(
              reciter: _filteredReciters[index],
              isDarkMode: isDarkMode,
              onTap: () => _showReciterDetails(_filteredReciters[index]),
            );
          },
        );
      },
    );
  }

  void _showReciterDetails(Reciter reciter) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ReciterDetailsSheet(
        reciter: reciter,
        onPlay: (moshaf) {
          Navigator.pop(context);
          _playRecitation(reciter, moshaf);
        },
      ),
    );
  }

  void _playRecitation(Reciter reciter, Moshaf moshaf) async {
    if (!_isInitialized) {
      _showErrorSnackBar('لم يتم تهيئة مشغل الصوت بشكل صحيح');
      return;
    }

    final selectedSurah = await _showSurahSelectionDialog();
    if (selectedSurah == null) return;

    _showLoadingDialog();

    try {
      _currentReciter = reciter;
      _currentMoshaf = moshaf;
      _currentSurahNumber = selectedSurah;
      _currentSurahNotifier = ValueNotifier<int>(selectedSurah);
      final audioUrl = _buildAudioUrl(moshaf.server, selectedSurah);
      final surahName = _getSurahName(selectedSurah);

      await _playAudio(audioUrl, reciter.name, surahName);

      Navigator.pop(context); // Remove loading dialog
      _showAudioPlayer(reciter, moshaf, selectedSurah);
    } catch (e) {
      Navigator.pop(context); // Remove loading dialog
      _showErrorSnackBar(_getErrorMessage(e));
    }
  }

  String _buildAudioUrl(String server, int surah) {
    String serverUrl = server;
    if (!serverUrl.endsWith('/')) serverUrl = '$serverUrl/';
    return '$serverUrl${surah.toString().padLeft(3, '0')}.mp3';
  }

  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('404')) {
      return 'لم يتم العثور على التلاوة المطلوبة';
    }
    return 'حدث خطأ أثناء تحميل التلاوة';
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            AppText('جاري تحميل التلاوة...', fontSize: 16),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Don't stop audio when navigating away
    _audioPlayer.dispose();
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<int?> _showSurahSelectionDialog() async {
    final surahs = {
      1: 'الفاتحة',
      2: 'البقرة',
      3: 'آل عمران',
      4: 'النساء',
      5: 'المائدة',
      6: 'الأنعام',
      7: 'الأعراف',
      8: 'الأنفال',
      9: 'التوبة',
      10: 'يونس',
      11: 'هود',
      12: 'يوسف',
      13: 'الرعد',
      14: 'إبراهيم',
      15: 'الحجر',
      16: 'النحل',
      17: 'الإسراء',
      18: 'الكهف',
      19: 'مريم',
      20: 'طه',
      21: 'الأنبياء',
      22: 'الحج',
      23: 'المؤمنون',
      24: 'النور',
      25: 'الفرقان',
      26: 'الشعراء',
      27: 'النمل',
      28: 'القصص',
      29: 'العنكبوت',
      30: 'الروم',
      31: 'لقمان',
      32: 'السجدة',
      33: 'الأحزاب',
      34: 'سبأ',
      35: 'فاطر',
      36: 'يس',
      37: 'الصافات',
      38: 'ص',
      39: 'الزمر',
      40: 'غافر',
      41: 'فصلت',
      42: 'الشورى',
      43: 'الزخرف',
      44: 'الدخان',
      45: 'الجاثية',
      46: 'الأحقاف',
      47: 'محمد',
      48: 'الفتح',
      49: 'الحجرات',
      50: 'ق',
      51: 'الذاريات',
      52: 'الطور',
      53: 'النجم',
      54: 'القمر',
      55: 'الرحمن',
      56: 'الواقعة',
      57: 'الحديد',
      58: 'المجادلة',
      59: 'الحشر',
      60: 'الممتحنة',
      61: 'الصف',
      62: 'الجمعة',
      63: 'المنافقون',
      64: 'التغابن',
      65: 'الطلاق',
      66: 'التحريم',
      67: 'الملك',
      68: 'القلم',
      69: 'الحاقة',
      70: 'المعارج',
      71: 'نوح',
      72: 'الجن',
      73: 'المزمل',
      74: 'المدثر',
      75: 'القيامة',
      76: 'الإنسان',
      77: 'المرسلات',
      78: 'النبأ',
      79: 'النازعات',
      80: 'عبس',
      81: 'التكوير',
      82: 'الانفطار',
      83: 'المطففين',
      84: 'الانشقاق',
      85: 'البروج',
      86: 'الطارق',
      87: 'الأعلى',
      88: 'الغاشية',
      89: 'الفجر',
      90: 'البلد',
      91: 'الشمس',
      92: 'الليل',
      93: 'الضحى',
      94: 'الشرح',
      95: 'التين',
      96: 'العلق',
      97: 'القدر',
      98: 'البينة',
      99: 'الزلزلة',
      100: 'العاديات',
      101: 'القارعة',
      102: 'التكاثر',
      103: 'العصر',
      104: 'الهمزة',
      105: 'الفيل',
      106: 'قريش',
      107: 'الماعون',
      108: 'الكوثر',
      109: 'الكافرون',
      110: 'النصر',
      111: 'المسد',
      112: 'الإخلاص',
      113: 'الفلق',
      114: 'الناس',
    };

    return showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const AppText(
          'اختر السورة',
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.6,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.8,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: surahs.length,
            itemBuilder: (context, index) {
              final surahNumber = index + 1;
              final surahName = surahs[surahNumber]!;
              return InkWell(
                onTap: () => Navigator.pop(context, surahNumber),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppText(
                        surahNumber.toString(),
                        fontSize: 12,
                        color: AppColors.primaryColor,
                      ),
                      const SizedBox(height: 1),
                      AppText(
                        surahName,
                        fontSize: 10,
                        color: AppColors.primaryColor,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showAudioPlayer(Reciter reciter, Moshaf moshaf, int selectedSurah) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isDismissible: true,
      builder: (context) => WillPopScope(
        onWillPop: () async {
          // Don't stop audio when closing the player UI
          return true;
        },
        child: NotificationListener<DraggableScrollableNotification>(
          onNotification: (notification) {
            // Don't stop audio when dragging down
            return true;
          },
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xff2F2F2F)
                      : Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_currentSurahNotifier != null)
                      ValueListenableBuilder<int>(
                        valueListenable: _currentSurahNotifier!,
                        builder: (context, surahNumber, _) {
                          return _buildPlayerHeader(
                              reciter, moshaf, surahNumber);
                        },
                      )
                    else
                      _buildPlayerHeader(reciter, moshaf, selectedSurah),
                    const SizedBox(height: 24),
                    _buildPlayerControls(),
                    const SizedBox(height: 24),
                    _buildProgressBar(),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.queue_music, color: Colors.teal),
                              const SizedBox(width: 8),
                              const Text('تشغيل السورة التالية تلقائياً',
                                  style: TextStyle(fontSize: 16)),
                            ],
                          ),
                          Switch(
                            value: _autoPlayNextSura,
                            onChanged: (val) {
                              setSheetState(() {
                                _autoPlayNextSura = val;
                              });
                              setState(() {
                                _autoPlayNextSura = val;
                              });
                            },
                            activeColor: AppColors.primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerHeader(Reciter reciter, Moshaf moshaf, int selectedSurah) {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            color: Color.fromRGBO(0, 150, 136, 0.1),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 150, 136, 0.2),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: AppText(
              reciter.letter,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(reciter.name, fontSize: 20, fontWeight: FontWeight.bold),
              const SizedBox(height: 4),
              AppText(
                '${moshaf.name} - ${_getSurahName(selectedSurah)}',
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
            // Don't stop audio when closing the player UI
          },
        ),
      ],
    );
  }

  Widget _buildPlayerControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildControlButton(
          icon: Icons.replay_10,
          onPressed: () => _seekBackward(),
        ),
        const SizedBox(width: 16),
        _buildPlayPauseButton(),
        const SizedBox(width: 16),
        _buildControlButton(
          icon: Icons.forward_10,
          onPressed: () => _seekForward(),
        ),
      ],
    );
  }

  Widget _buildPlayPauseButton() {
    return StreamBuilder<PlayerState>(
      stream: _audioPlayer.onPlayerStateChanged,
      builder: (context, snapshot) {
        final state = snapshot.data;
        final isPlaying = state == PlayerState.playing;

        return Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 150, 136, 0.3),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 32,
            ),
            onPressed: () {
              if (isPlaying) {
                _pauseAudio();
              } else {
                _resumeAudio();
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildProgressBar() {
    return StreamBuilder<Duration?>(
      stream: _audioPlayer.onPositionChanged,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        return StreamBuilder<Duration?>(
          stream: _audioPlayer.onDurationChanged,
          builder: (context, snapshot) {
            final duration = snapshot.data ?? Duration.zero;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (duration.inSeconds > 0) ...[
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 12,
                      ),
                      activeTrackColor: AppColors.primaryColor,
                      inactiveTrackColor: Colors.grey[300],
                      thumbColor: AppColors.primaryColor,
                      overlayColor: const Color.fromRGBO(0, 150, 136, 0.2),
                    ),
                    child: Slider(
                      value: position.inSeconds.toDouble().clamp(
                            0.0,
                            duration.inSeconds.toDouble(),
                          ),
                      max: duration.inSeconds.toDouble(),
                      onChanged: (value) => _seekTo(value.toInt()),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppText(
                          _formatDuration(position),
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        AppText(
                          _formatDuration(duration),
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 20),
                  StreamBuilder<PlayerState>(
                    stream: _audioPlayer.onPlayerStateChanged,
                    builder: (context, snapshot) {
                      final state = snapshot.data;
                      if (state == PlayerState.playing ||
                          state == PlayerState.completed ||
                          state == PlayerState.paused) {
                        return const SizedBox.shrink();
                      }
                      return Column(
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          AppText(
                            'جاري تحميل التلاوة...',
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  String _getSurahName(int surahNumber) {
    final surahs = {
      1: 'الفاتحة',
      2: 'البقرة',
      3: 'آل عمران',
      4: 'النساء',
      5: 'المائدة',
      6: 'الأنعام',
      7: 'الأعراف',
      8: 'الأنفال',
      9: 'التوبة',
      10: 'يونس',
      11: 'هود',
      12: 'يوسف',
      13: 'الرعد',
      14: 'إبراهيم',
      15: 'الحجر',
      16: 'النحل',
      17: 'الإسراء',
      18: 'الكهف',
      19: 'مريم',
      20: 'طه',
      21: 'الأنبياء',
      22: 'الحج',
      23: 'المؤمنون',
      24: 'النور',
      25: 'الفرقان',
      26: 'الشعراء',
      27: 'النمل',
      28: 'القصص',
      29: 'العنكبوت',
      30: 'الروم',
      31: 'لقمان',
      32: 'السجدة',
      33: 'الأحزاب',
      34: 'سبأ',
      35: 'فاطر',
      36: 'يس',
      37: 'الصافات',
      38: 'ص',
      39: 'الزمر',
      40: 'غافر',
      41: 'فصلت',
      42: 'الشورى',
      43: 'الزخرف',
      44: 'الدخان',
      45: 'الجاثية',
      46: 'الأحقاف',
      47: 'محمد',
      48: 'الفتح',
      49: 'الحجرات',
      50: 'ق',
      51: 'الذاريات',
      52: 'الطور',
      53: 'النجم',
      54: 'القمر',
      55: 'الرحمن',
      56: 'الواقعة',
      57: 'الحديد',
      58: 'المجادلة',
      59: 'الحشر',
      60: 'الممتحنة',
      61: 'الصف',
      62: 'الجمعة',
      63: 'المنافقون',
      64: 'التغابن',
      65: 'الطلاق',
      66: 'التحريم',
      67: 'الملك',
      68: 'القلم',
      69: 'الحاقة',
      70: 'المعارج',
      71: 'نوح',
      72: 'الجن',
      73: 'المزمل',
      74: 'المدثر',
      75: 'القيامة',
      76: 'الإنسان',
      77: 'المرسلات',
      78: 'النبأ',
      79: 'النازعات',
      80: 'عبس',
      81: 'التكوير',
      82: 'الانفطار',
      83: 'المطففين',
      84: 'الانشقاق',
      85: 'البروج',
      86: 'الطارق',
      87: 'الأعلى',
      88: 'الغاشية',
      89: 'الفجر',
      90: 'البلد',
      91: 'الشمس',
      92: 'الليل',
      93: 'الضحى',
      94: 'الشرح',
      95: 'التين',
      96: 'العلق',
      97: 'القدر',
      98: 'البينة',
      99: 'الزلزلة',
      100: 'العاديات',
      101: 'القارعة',
      102: 'التكاثر',
      103: 'العصر',
      104: 'الهمزة',
      105: 'الفيل',
      106: 'قريش',
      107: 'الماعون',
      108: 'الكوثر',
      109: 'الكافرون',
      110: 'النصر',
      111: 'المسد',
      112: 'الإخلاص',
      113: 'الفلق',
      114: 'الناس',
    };
    return surahs[surahNumber] ?? 'سورة $surahNumber';
  }

  Future<void> _seekBackward() async {
    try {
      final position = await _audioPlayer.getCurrentPosition();
      if (position != null) {
        final newPosition = position - const Duration(seconds: 10);
        await _audioPlayer.seek(
          newPosition.inSeconds > 0 ? newPosition : Duration.zero,
        );
      }
    } catch (e) {
      debugPrint('Error seeking backward: $e');
    }
  }

  Future<void> _seekForward() async {
    try {
      final position = await _audioPlayer.getCurrentPosition();
      final duration = await _audioPlayer.getDuration();
      if (position != null && duration != null) {
        final newPosition = position + const Duration(seconds: 10);
        await _audioPlayer.seek(
          newPosition <= duration ? newPosition : duration,
        );
      }
    } catch (e) {
      debugPrint('Error seeking forward: $e');
    }
  }

  Future<void> _seekTo(int seconds) async {
    try {
      await _audioPlayer.seek(Duration(seconds: seconds));
    } catch (e) {
      debugPrint('Error seeking: $e');
    }
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        color: Color.fromRGBO(0, 150, 136, 0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.primaryColor, size: 24),
        onPressed: onPressed,
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isDarkMode;
  final Function(String) onChanged;

  const _SearchBar({
    required this.controller,
    required this.isDarkMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(
          fontFamily: 'DIN',
          fontSize: 16,
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: 'ابحث عن قارئ...',
          hintStyle: TextStyle(
            fontFamily: 'DIN',
            fontSize: 16,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
          prefixIcon: Icon(
            Icons.search,
            color: isDarkMode ? Colors.grey[400] : AppColors.primaryColor,
          ),
          filled: true,
          fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppText(error, fontSize: 16, color: Colors.red),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const AppText('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}

class _ReciterCard extends StatelessWidget {
  final Reciter reciter;
  final bool isDarkMode;
  final VoidCallback onTap;

  const _ReciterCard({
    required this.reciter,
    required this.isDarkMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: isDarkMode ? const Color(0xff2F2F2F) : Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              if (reciter.moshaf.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Divider(height: 1),
                const SizedBox(height: 16),
                ...reciter.moshaf.map((moshaf) => _buildMoshafItem(moshaf)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        _buildAvatar(),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                reciter.name,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : AppColors.primaryColor,
              ),
              if (reciter.moshaf.isNotEmpty) ...[
                const SizedBox(height: 6),
                AppText(
                  'عدد المصاحف: ${reciter.moshaf.length}',
                  fontSize: 14,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.grey[800]
            : AppColors.primaryColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: AppText(
          reciter.letter,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.white : AppColors.primaryColor,
        ),
      ),
    );
  }

  Widget _buildMoshafItem(Moshaf moshaf) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.grey[800]
                  : AppColors.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.book,
              size: 18,
              color: isDarkMode ? Colors.grey[400] : AppColors.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppText(
              moshaf.name,
              fontSize: 15,
              color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReciterDetailsSheet extends StatelessWidget {
  final Reciter reciter;
  final Function(Moshaf) onPlay;

  const _ReciterDetailsSheet({required this.reciter, required this.onPlay});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xff2F2F2F) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(isDarkMode),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reciter.moshaf.length,
              itemBuilder: (context, index) {
                final moshaf = reciter.moshaf[index];
                return _MoshafListItem(
                  moshaf: moshaf,
                  onPlay: () => onPlay(moshaf),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xff1F1F1F) : AppColors.primaryColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          _buildAvatar(isDarkMode),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  reciter.name,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                const SizedBox(height: 4),
                AppText(
                  'عدد المصاحف: ${reciter.moshaf.length}',
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isDarkMode) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color:
            isDarkMode ? Colors.grey[800] : Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: AppText(
          reciter.letter,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _MoshafListItem extends StatelessWidget {
  final Moshaf moshaf;
  final VoidCallback onPlay;

  const _MoshafListItem({required this.moshaf, required this.onPlay});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.book, color: AppColors.primaryColor),
        ),
        title: AppText(moshaf.name, fontSize: 16, fontWeight: FontWeight.bold),
        subtitle: AppText(
          'عدد السور: ${moshaf.surahTotal}',
          fontSize: 14,
          color: Colors.grey[600],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.play_circle_outline),
          onPressed: onPlay,
        ),
      ),
    );
  }
}
