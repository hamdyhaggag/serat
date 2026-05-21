import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:serat/Business_Logic/Cubit/reciters_cubit.dart';
import 'package:serat/Business_Logic/Cubit/download_cubit.dart';
import 'package:serat/Business_Logic/Models/reciter_model.dart';
import 'package:serat/Business_Logic/Models/download_model.dart';
import 'package:serat/Data/services/audio_player_service.dart';
import 'package:serat/imports.dart';
import 'package:flutter/foundation.dart';
import 'package:serat/Presentation/Widgets/reciters/download_manager_widget.dart';
import 'package:serat/Presentation/Widgets/reciters/quran_audio_player_widget.dart';
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
  final ValueNotifier<Duration> _positionNotifier = ValueNotifier(Duration.zero);
  final ValueNotifier<Duration> _durationNotifier = ValueNotifier(Duration.zero);
  final ValueNotifier<PlayerState> _playerStateNotifier = ValueNotifier(PlayerState.stopped);

  @override
  void initState() {
    super.initState();
    _initializeAudio();
    _initializeNotificationService();
    _loadReciters();
    _setupAnimation();
    _setupSearchListener();

    // Initialize downloads after first frame to ensure context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await DownloadCubit.get(context).initialize();
        await DownloadCubit.get(context).loadStorageInfo();
      } catch (_) {}
    });
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
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
      _playerStateNotifier.value = PlayerState.completed;
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
      _playerStateNotifier.value = state;
      if (mounted) setState(() => _isPlaying = state == PlayerState.playing);
    });

    _audioPlayer.onPositionChanged.listen((pos) {
      _positionNotifier.value = pos;
    });

    _audioPlayer.onDurationChanged.listen((dur) {
      _durationNotifier.value = dur;
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

      // Reset values
      _positionNotifier.value = Duration.zero;
      _durationNotifier.value = Duration.zero;
      _playerStateNotifier.value = PlayerState.stopped;

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
      _positionNotifier.value = Duration.zero;
      _durationNotifier.value = Duration.zero;
      _playerStateNotifier.value = PlayerState.stopped;

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

  Future<void> _loadReciters() async {
    try {
      if (!mounted) return;
      await RecitersCubit.get(context).getReciters();
      if (!mounted) return;

      final state = RecitersCubit.get(context).state;
      if (state is RecitersError) {
        setState(() => _isOfflineMode = true);
        _showErrorSnackBar('تعذر الاتصال بالشبكة، يرجى المحاولة لاحقاً');
      } else {
        setState(() => _isOfflineMode = false);
        _filterReciters(_searchController.text);
      }
    } catch (e) {
      if (!mounted) return;
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
      backgroundColor: isDarkMode ? const Color(0xff121212) : const Color(0xffF8FAF9),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(isDarkMode),
          _buildSliverSearch(isDarkMode),
          _buildSliverList(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(bool isDarkMode) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      stretch: true,
      backgroundColor: isDarkMode ? const Color(0xff1A2B25) : AppColors.primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.blurBackground, StretchMode.zoomBackground],
        centerTitle: true,
        title: const AppText(
          'القـراء',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: 'Cairo',
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDarkMode 
                    ? [const Color(0xff1A2B25), const Color(0xff121212)]
                    : [AppColors.primaryColor, const Color(0xff138A70)],
                ),
              ),
            ),
            Positioned(
              right: -50,
              top: -50,
              child: Icon(
                Icons.mosque,
                size: 200,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.cloud_download_outlined, color: Colors.white),
          onPressed: () => _showDownloadManager(),
        ),
        _buildOfflineBadge(),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildOfflineBadge() {
    if (!_isOfflineMode) return const SizedBox.shrink();
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.withOpacity(0.5)),
        ),
        child: const Icon(Icons.cloud_off, color: Colors.orange, size: 16),
      ),
    );
  }

  Widget _buildSliverSearch(bool isDarkMode) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        child: _SearchBar(
          controller: _searchController,
          isDarkMode: isDarkMode,
          onChanged: _filterReciters,
        ),
      ),
    );
  }

  Widget _buildSliverList(bool isDarkMode) {
    return BlocBuilder<RecitersCubit, RecitersState>(
      builder: (context, state) {
        if (state is RecitersLoading && !_isOfflineMode) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final cubit = RecitersCubit.get(context);

        if (_isOfflineMode && (cubit.recitersModel?.reciters.isEmpty ?? true)) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const AppText('لا يوجد اتصال بالإنترنت', fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold),
                  const SizedBox(height: 8),
                  const AppText('تأكد من اتصالك بالشبكة للمتابعة', fontSize: 14, color: Colors.grey),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() => _isOfflineMode = false);
                      _loadReciters();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const AppText('إعادة المحاولة', color: Colors.white),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
                  )
                ],
              ),
            ),
          );
        }

        if (state is RecitersError && !_isOfflineMode) {
          return SliverFillRemaining(
            child: _ErrorView(
              error: cubit.error ?? 'حدث خطأ غير معروف',
              onRetry: () {
                setState(() => _isOfflineMode = false);
                _loadReciters();
              },
            ),
          );
        }

        if (cubit.recitersModel?.reciters.isEmpty ?? true) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const AppText('لا يوجد قراء يطابقون بحثك', fontSize: 16, color: Colors.grey),
                ],
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return _ReciterCard(
                  reciter: _filteredReciters[index],
                  isDarkMode: isDarkMode,
                  onTap: () => _showReciterDetails(_filteredReciters[index]),
                );
              },
              childCount: _filteredReciters.length,
            ),
          ),
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
        onDownload: (moshaf) {
          Navigator.pop(context);
          _showDownloadOptions(reciter, moshaf);
        },
      ),
    );
  }

  void _showDownloadManager() {
    // Load storage info before opening the manager to avoid endless loader
    DownloadCubit.get(context).loadStorageInfo();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const DownloadManagerWidget(),
    );
  }

  void _showDownloadOptions(Reciter reciter, Moshaf moshaf) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _DownloadOptionsSheet(
        reciter: reciter,
        moshaf: moshaf,
        onDownloadSurah: (surahNumber) {
          Navigator.pop(context);
          _downloadSurah(reciter, moshaf, surahNumber);
        },
        onDownloadMultiple: (surahNumbers) {
          Navigator.pop(context);
          _downloadMultipleSurahs(reciter, moshaf, surahNumbers);
        },
      ),
    );
  }

  void _downloadSurah(Reciter reciter, Moshaf moshaf, int surahNumber) {
    // Show progress UI BEFORE starting download to capture all state changes
    _showInlineDownloadProgress(reciter, moshaf, surahNumber);

    DownloadCubit.get(context).downloadSurah(
      reciter: reciter,
      moshaf: moshaf,
      surahNumber: surahNumber,
    );
  }

  void _downloadMultipleSurahs(
      Reciter reciter, Moshaf moshaf, List<int> surahNumbers) {
    DownloadCubit.get(context).downloadMultipleSurahs(
      reciter: reciter,
      moshaf: moshaf,
      surahNumbers: surahNumbers,
    );

    // Show an inline batch progress if desired (optional)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            AppText('بدأ تحميل ${surahNumbers.length} سورة لِ ${reciter.name}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showInlineDownloadProgress(
    Reciter reciter,
    Moshaf moshaf,
    int surahNumber,
  ) {
    final messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(hours: 1), // will be closed on complete/error
        content: BlocConsumer<DownloadCubit, DownloadState>(
          listener: (context, state) async {
            if (state is DownloadProgressUpdated &&
                state.progress.reciterId == reciter.id.toString() &&
                state.progress.moshafId == moshaf.id.toString() &&
                state.progress.surahNumber == surahNumber &&
                state.progress.status == DownloadStatus.completed) {
              messenger.hideCurrentSnackBar();

              // Offer to play now
              messenger.showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 5),
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AppText(
                          'تم تحميل سورة ${_getSurahName(surahNumber)} لِ ${reciter.name}',
                          fontSize: 14,
                        ),
                      ),
                      Builder(
                        builder: (btnCtx) {
                          final capturedCubit = DownloadCubit.get(btnCtx);
                          return TextButton(
                            onPressed: () async {
                              // Avoid using outer (possibly deactivated) context
                              final path =
                                  await capturedCubit.getOfflineAudioPath(
                                reciter.id.toString(),
                                moshaf.id.toString(),
                                surahNumber,
                              );
                              if (path != null) {
                                final player = AudioPlayerService();
                                await player.initialize();
                                await player.playRecitation(
                                  reciter: reciter,
                                  moshaf: moshaf,
                                  surahNumber: surahNumber,
                                );
                              }
                            },
                            child: const AppText('تشغيل الآن',
                                color: Colors.white),
                          );
                        },
                      ),
                    ],
                  ),
                  backgroundColor: Colors.green.withValues(alpha: 0.9),
                ),
              );
            }
          },
          builder: (context, state) {
            // Capture cubit now so we don't access context after widget disposal
            final downloadCubit = DownloadCubit.get(context);

            DownloadProgress? p;
            if (state is DownloadProgressUpdated &&
                state.progress.reciterId == reciter.id.toString() &&
                state.progress.moshafId == moshaf.id.toString() &&
                state.progress.surahNumber == surahNumber) {
              p = state.progress;
            }

            final value = (p?.progress ?? 0.0).clamp(0.0, 1.0);
            final status = p?.status ?? DownloadStatus.downloading;

            return Row(
              children: [
                const Icon(Icons.downloading, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        'تحميل ${_getSurahName(surahNumber)} لِ ${reciter.name}',
                        fontSize: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value:
                              status == DownloadStatus.completed ? 1.0 : value,
                          backgroundColor: Colors.white.withValues(alpha: 0.25),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            status == DownloadStatus.failed
                                ? Colors.red
                                : Colors.white,
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                AppText('${(value * 100).toStringAsFixed(0)}%',
                    color: Colors.white),
              ],
            );
          },
        ),
        backgroundColor: AppColors.primaryColor,
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
    _positionNotifier.dispose();
    _durationNotifier.dispose();
    _playerStateNotifier.dispose();
    super.dispose();
  }

  Future<int?> _showSurahSelectionDialog() async {
    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SurahSelectionSheet(
        surahs: _getSurahsMap(),
      ),
    );
  }

  Map<int, String> _getSurahsMap() {
    return {
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
  }

  void _showAudioPlayer(Reciter reciter, Moshaf moshaf, int selectedSurah) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return QuranAudioPlayerWidget(
            reciter: reciter,
            moshaf: moshaf,
            surahNumber: _currentSurahNumber ?? selectedSurah,
            surahName: _currentSurahName,
            autoPlayNext: _autoPlayNextSura,
            onAutoPlayChanged: (val) {
              setSheetState(() => _autoPlayNextSura = val);
              setState(() => _autoPlayNextSura = val);
            },
            onPlayPause: () {
              if (_isPlaying) {
                _pauseAudio();
              } else {
                _resumeAudio();
              }
            },
            onPrevious: _playPreviousSurah,
            onNext: _playNextSurah,
            onSeekForward: _seekForward,
            onSeekBackward: _seekBackward,
            onSeek: _seekTo,
            positionNotifier: _positionNotifier,
            durationNotifier: _durationNotifier,
            playerStateNotifier: _playerStateNotifier,
            onDownload: () => _downloadSurah(
              reciter,
              moshaf,
              _currentSurahNumber ?? selectedSurah,
            ),
            onClose: () => Navigator.pop(context),
            onDelete: () async {
              await DownloadCubit.get(context).deleteDownloadedSurah(
                reciter.id.toString(),
                moshaf.id.toString(),
                _currentSurahNumber ?? selectedSurah,
              );
              await DownloadCubit.get(context).loadStorageInfo();
            },
          );
        },
      ),
    );
  }

  void _playNextSurah() async {
    if (_currentSurahNumber == null || _currentMoshaf == null || _currentReciter == null) return;
    
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
        await _playAudio(audioUrl, _currentReciter!.name, surahName);
      } catch (e) {
        _showErrorSnackBar('حدث خطأ أثناء تشغيل السورة التالية');
      }
    } else {
      _showErrorSnackBar('لا توجد سورة تالية في هذا المصحف');
    }
  }

  void _playPreviousSurah() async {
    if (_currentSurahNumber == null || _currentMoshaf == null || _currentReciter == null) return;
    
    final surahList = _currentMoshaf!.surahList
        .split(',')
        .map((e) => int.tryParse(e.trim()))
        .whereType<int>()
        .toList();
    final idx = surahList.indexOf(_currentSurahNumber!);
    
    if (idx != -1 && idx - 1 >= 0) {
      final prevSurah = surahList[idx - 1];
      final audioUrl = _buildAudioUrl(_currentMoshaf!.server, prevSurah);
      final surahName = _getSurahName(prevSurah);
      
      setState(() {
        _currentSurahNumber = prevSurah;
        _currentSurahName = surahName;
      });
      _currentSurahNotifier?.value = prevSurah;
      
      try {
        await _playAudio(audioUrl, _currentReciter!.name, surahName);
      } catch (e) {
        _showErrorSnackBar('حدث خطأ أثناء تشغيل السورة السابقة');
      }
    } else {
      _showErrorSnackBar('لا توجد سورة سابقة في هذا المصحف');
    }
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
          fontFamily: 'Cairo',
          fontSize: 14,
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: 'ابحث عن قارئ...',
          hintStyle: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xff1E2923) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: isDarkMode 
            ? Colors.white.withOpacity(0.05) 
            : AppColors.primaryColor.withOpacity(0.05),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildAvatar(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        reciter.name,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : const Color(0xff1A1A1A),
                        fontFamily: 'Cairo',
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.library_books_outlined, size: 12, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          AppText(
                            '${reciter.moshaf.length} مصاحف متوفرة',
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontFamily: 'Cairo',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: AppColors.primaryColor,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.grey[800]
            : AppColors.primaryColor.withOpacity(0.1),
        shape: BoxShape.circle,
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
}

class _SurahSelectionSheet extends StatefulWidget {
  final Map<int, String> surahs;

  const _SurahSelectionSheet({required this.surahs});

  @override
  State<_SurahSelectionSheet> createState() => _SurahSelectionSheetState();
}

class _SurahSelectionSheetState extends State<_SurahSelectionSheet> {
  late List<MapEntry<int, String>> _filteredSurahs;

  @override
  void initState() {
    super.initState();
    _filteredSurahs = widget.surahs.entries.toList();
  }

  void _filterSurahs(String query) {
    setState(() {
      _filteredSurahs = widget.surahs.entries
          .where((entry) => 
              entry.value.contains(query) || 
              entry.key.toString().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xff121212) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                const AppText(
                  'اختر السورة',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextField(
              onChanged: _filterSurahs,
              decoration: InputDecoration(
                hintText: 'ابحث عن سورة...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Colors.grey[isDarkMode ? 900 : 100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _filteredSurahs.length,
              itemBuilder: (context, index) {
                final surah = _filteredSurahs[index];
                return InkWell(
                  onTap: () => Navigator.pop(context, surah.key),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primaryColor.withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppText(
                          surah.key.toString(),
                          fontSize: 12,
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                        const SizedBox(height: 4),
                        AppText(
                          surah.value,
                          fontSize: 12,
                          color: isDarkMode ? Colors.white : Colors.black87,
                          fontFamily: 'Cairo',
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
        ],
      ),
    );
  }
}


class _DownloadOptionsSheet extends StatelessWidget {
  final Reciter reciter;
  final Moshaf moshaf;
  final Function(int) onDownloadSurah;
  final Function(List<int>) onDownloadMultiple;

  const _DownloadOptionsSheet({
    required this.reciter,
    required this.moshaf,
    required this.onDownloadSurah,
    required this.onDownloadMultiple,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppText(
            'خيارات التحميل',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: Icon(Icons.download, color: AppColors.primaryColor),
            title: const AppText('تحميل سورة واحدة'),
            onTap: () => _showSurahSelection(context),
          ),
          ListTile(
            leading: Icon(Icons.download_done, color: AppColors.primaryColor),
            title: const AppText('تحميل عدة سور'),
            onTap: () => _showMultipleSurahSelection(context),
          ),
          ListTile(
            leading:
                Icon(Icons.download_for_offline, color: AppColors.primaryColor),
            title: const AppText('تحميل جميع السور'),
            onTap: () => _downloadAllSurahs(context),
          ),
        ],
      ),
    );
  }

  void _showSurahSelection(BuildContext context) async {
    final allowed = moshaf.surahList
        .split(',')
        .map((e) => int.tryParse(e.trim()))
        .whereType<int>()
        .toSet();
    final surahNumbers = allowed.isEmpty
        ? List<int>.generate(114, (i) => i + 1)
        : allowed.toList()
      ..sort();

    final selected = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const AppText('اختر السورة',
            fontSize: 18, fontWeight: FontWeight.bold),
        content: SizedBox(
          width: double.maxFinite,
          height: MediaQuery.of(ctx).size.height * 0.6,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.8,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: surahNumbers.length,
            itemBuilder: (c, i) {
              final n = surahNumbers[i];
              return InkWell(
                onTap: () => Navigator.pop(ctx, n),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: AppText(
                      _getSurahName(n),
                      fontSize: 14,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    if (selected != null) {
      onDownloadSurah(selected);
    }
  }

  void _showMultipleSurahSelection(BuildContext context) async {
    final allowed = moshaf.surahList
        .split(',')
        .map((e) => int.tryParse(e.trim()))
        .whereType<int>()
        .toSet();
    final surahNumbers = allowed.isEmpty
        ? List<int>.generate(114, (i) => i + 1)
        : allowed.toList()
      ..sort();

    final chosen = <int>{};

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const AppText('اختر عدة سور',
              fontSize: 18, fontWeight: FontWeight.bold),
          content: SizedBox(
            width: double.maxFinite,
            height: MediaQuery.of(ctx).size.height * 0.6,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.8,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: surahNumbers.length,
              itemBuilder: (c, i) {
                final n = surahNumbers[i];
                final isSel = chosen.contains(n);
                return InkWell(
                  onTap: () {
                    setState(() {
                      if (isSel) {
                        chosen.remove(n);
                      } else {
                        chosen.add(n);
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSel
                          ? AppColors.primaryColor.withValues(alpha: 0.25)
                          : AppColors.primaryColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: AppText(
                        _getSurahName(n),
                        fontSize: 14,
                        color: isSel ? Colors.white : AppColors.primaryColor,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const AppText('إلغاء'),
            ),
            ElevatedButton(
              onPressed: chosen.isEmpty ? null : () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white),
              child: const AppText('تحميل'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && chosen.isNotEmpty) {
      onDownloadMultiple(chosen.toList()..sort());
    }
  }

  void _downloadAllSurahs(BuildContext context) {
    final surahList = moshaf.surahList
        .split(',')
        .map((e) => int.tryParse(e.trim()))
        .whereType<int>()
        .toList();
    onDownloadMultiple(surahList);
    Navigator.pop(context);
  }

  String _getSurahName(int surahNumber) {
    const surahs = {
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
}

class _ReciterDetailsSheet extends StatelessWidget {
  final Reciter reciter;
  final Function(Moshaf) onPlay;
  final Function(Moshaf)? onDownload;

  const _ReciterDetailsSheet({
    required this.reciter,
    required this.onPlay,
    this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xff121212) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[isDarkMode ? 800 : 300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          _buildHeader(isDarkMode),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              itemCount: reciter.moshaf.length,
              itemBuilder: (context, index) {
                final moshaf = reciter.moshaf[index];
                return _MoshafListItem(
                  moshaf: moshaf,
                  isDarkMode: isDarkMode,
                  onPlay: () => onPlay(moshaf),
                  onDownload: onDownload != null ? () => onDownload!(moshaf) : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(24),
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
                  color: isDarkMode ? Colors.white : Colors.black87,
                  fontFamily: 'Cairo',
                ),
                const SizedBox(height: 4),
                AppText(
                  'اختر نوع المصحف للبدء',
                  fontSize: 14,
                  color: Colors.grey[500],
                  fontFamily: 'Cairo',
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: AppText(
              '${reciter.moshaf.length} نوع',
              fontSize: 12,
              color: AppColors.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isDarkMode) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primaryColor.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Center(
        child: AppText(
          reciter.letter,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }
}

class _MoshafListItem extends StatelessWidget {
  final Moshaf moshaf;
  final bool isDarkMode;
  final VoidCallback onPlay;
  final VoidCallback? onDownload;

  const _MoshafListItem({
    required this.moshaf,
    required this.isDarkMode,
    required this.onPlay,
    this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xff1A231F) : const Color(0xffF0F4F2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryColor.withOpacity(0.1),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPlay,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(isDarkMode ? 0.05 : 0.5),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    Icons.library_music_rounded,
                    color: AppColors.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        moshaf.name,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                        fontFamily: 'Cairo',
                      ),
                      const SizedBox(height: 2),
                      AppText(
                        'عرض مفصل للسور المتاحة',
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontFamily: 'Cairo',
                      ),
                    ],
                  ),
                ),
                if (onDownload != null)
                  IconButton(
                    onPressed: onDownload,
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                      padding: const EdgeInsets.all(8),
                    ),
                    icon: Icon(
                      Icons.cloud_download_outlined,
                      color: AppColors.primaryColor,
                      size: 20,
                    ),
                  ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
