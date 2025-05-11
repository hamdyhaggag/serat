import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:serat/Business_Logic/Cubit/reciters_cubit.dart';
import 'package:serat/Business_Logic/Models/reciter_model.dart';
import 'package:serat/imports.dart';
import 'package:flutter/foundation.dart';

class RecitersScreen extends StatefulWidget {
  const RecitersScreen({super.key});

  @override
  State<RecitersScreen> createState() => _RecitersScreenState();
}

class _RecitersScreenState extends State<RecitersScreen>
    with SingleTickerProviderStateMixin {
  String? selectedLanguage;
  int? selectedReciterId;
  int? selectedRewayaId;
  int? selectedSuraId;
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  List<Reciter> _filteredReciters = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAudio();
    _loadReciters();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);
    _animationController.forward();

    // Add focus listener
    _searchController.addListener(() {
      if (!_searchController.text.isEmpty) {
        _filterReciters(_searchController.text);
      }
    });
  }

  Future<void> _initializeAudio() async {
    try {
      // Set up error handling
      _audioPlayer.onLog.listen((msg) {
        debugPrint('Audio player error: $msg');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: AppText(
                'حدث خطأ أثناء تشغيل التلاوة',
                color: Colors.white,
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      });

      // Set up completion handler
      _audioPlayer.onPlayerComplete.listen((_) {
        if (mounted) {
          setState(() {
            _isPlaying = false;
          });
        }
      });

      // Set up state change handler
      _audioPlayer.onPlayerStateChanged.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state == PlayerState.playing;
          });
        }
      });

      // Set initial volume
      await _audioPlayer.setVolume(1.0);

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('Error initializing audio: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: AppText(
              'لم يتم تهيئة مشغل الصوت بشكل صحيح',
              color: Colors.white,
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _loadReciters() {
    try {
      RecitersCubit.get(context)
          .getReciters(
            language: selectedLanguage,
            reciterId: selectedReciterId,
            rewayaId: selectedRewayaId,
            suraId: selectedSuraId,
          )
          .then((_) {
            _filterReciters(_searchController.text);
          })
          .catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: AppText(
                  'حدث خطأ أثناء تحميل بيانات القراء',
                  color: Colors.white,
                ),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
          });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: AppText(
            'حدث خطأ أثناء تحميل بيانات القراء',
            color: Colors.white,
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _filterReciters(String query) {
    final cubit = RecitersCubit.get(context);
    if (cubit.recitersModel == null) return;

    setState(() {
      if (query.isEmpty) {
        _filteredReciters = cubit.recitersModel!.reciters;
      } else {
        _filteredReciters =
            cubit.recitersModel!.reciters.where((reciter) {
              return reciter.name.toLowerCase().contains(query.toLowerCase()) ||
                  reciter.letter.toLowerCase().contains(query.toLowerCase());
            }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xff1F1F1F) : Colors.white,
      appBar: AppBar(
        title: const AppText(
          'القراء',
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        backgroundColor:
            isDarkMode ? const Color(0xff2F2F2F) : AppColors.primaryColor,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              decoration: BoxDecoration(
                color:
                    isDarkMode
                        ? const Color(0xff2F2F2F)
                        : AppColors.primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[800] : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
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
                          color:
                              isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color:
                              isDarkMode
                                  ? Colors.grey[400]
                                  : AppColors.primaryColor,
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
                      onChanged: _filterReciters,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(
                          'اللغة',
                          selectedLanguage ?? 'العربية',
                          onTap: () => _showLanguageDialog(),
                        ),
                        const SizedBox(width: 12),
                        _buildFilterChip(
                          'الرواية',
                          selectedRewayaId != null ? 'تم التحديد' : 'الكل',
                          onTap: () => _showRewayaDialog(),
                        ),
                        const SizedBox(width: 12),
                        _buildFilterChip(
                          'السورة',
                          selectedSuraId != null ? 'تم التحديد' : 'الكل',
                          onTap: () => _showSuraDialog(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<RecitersCubit, RecitersState>(
                builder: (context, state) {
                  final cubit = RecitersCubit.get(context);

                  if (state is RecitersLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is RecitersError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppText(
                            cubit.error ?? 'حدث خطأ غير معروف',
                            fontSize: 16,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadReciters,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
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

                  if (cubit.recitersModel?.reciters.isEmpty ?? true) {
                    return const Center(
                      child: AppText('لا يوجد قراء', fontSize: 16),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredReciters.length,
                    itemBuilder: (context, index) {
                      final reciter = _filteredReciters[index];
                      return _buildReciterCard(reciter, isDarkMode);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String value, {
    required VoidCallback onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[800] : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText(
                label,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : AppColors.primaryColor,
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color:
                      isDarkMode
                          ? Colors.grey[700]
                          : AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText(
                      value,
                      fontSize: 14,
                      color:
                          isDarkMode
                              ? Colors.grey[300]
                              : AppColors.primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_drop_down,
                      size: 20,
                      color:
                          isDarkMode
                              ? Colors.grey[300]
                              : AppColors.primaryColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReciterCard(Reciter reciter, bool isDarkMode) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: isDarkMode ? const Color(0xff2F2F2F) : Colors.white,
      child: InkWell(
        onTap: () {
          _showReciterDetails(reciter);
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color:
                          isDarkMode
                              ? Colors.grey[800]
                              : AppColors.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
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
                        color:
                            isDarkMode ? Colors.white : AppColors.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          reciter.name,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color:
                              isDarkMode
                                  ? Colors.white
                                  : AppColors.primaryColor,
                        ),
                        if (reciter.moshaf.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          AppText(
                            'عدد المصاحف: ${reciter.moshaf.length}',
                            fontSize: 14,
                            color:
                                isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (reciter.moshaf.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Divider(height: 1),
                const SizedBox(height: 16),
                ...reciter.moshaf.map(
                  (moshaf) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                isDarkMode
                                    ? Colors.grey[800]
                                    : AppColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.book,
                            size: 18,
                            color:
                                isDarkMode
                                    ? Colors.grey[400]
                                    : AppColors.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppText(
                            moshaf.name,
                            fontSize: 15,
                            color:
                                isDarkMode
                                    ? Colors.grey[300]
                                    : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showReciterDetails(Reciter reciter) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xff2F2F2F)
                      : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xff1F1F1F)
                            : AppColors.primaryColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey[800]
                                  : Colors.white.withOpacity(0.2),
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
                      ),
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
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: reciter.moshaf.length,
                    itemBuilder: (context, index) {
                      final moshaf = reciter.moshaf[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.book,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          title: AppText(
                            moshaf.name,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          subtitle: AppText(
                            'عدد السور: ${moshaf.surahTotal}',
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.play_circle_outline),
                            onPressed: () {
                              Navigator.pop(context);
                              _playRecitation(reciter, moshaf);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _playRecitation(Reciter reciter, Moshaf moshaf) async {
    if (!_isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: AppText(
            'لم يتم تهيئة مشغل الصوت بشكل صحيح',
            color: Colors.white,
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // Show surah selection dialog first
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

    final selectedSurah = await showDialog<int>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const AppText(
              'اختر السورة',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            content: Container(
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
                        color: AppColors.primaryColor.withOpacity(0.1),
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

    if (selectedSurah == null) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const AlertDialog(
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

    try {
      // Clean up the server URL to ensure it ends with a slash
      String serverUrl = moshaf.server;
      if (!serverUrl.endsWith('/')) {
        serverUrl = '$serverUrl/';
      }

      // Construct the audio URL with proper formatting
      final audioUrl =
          '$serverUrl${selectedSurah.toString().padLeft(3, '0')}.mp3';

      // Stop any currently playing audio
      await _audioPlayer.stop();

      // Set the audio source
      await _audioPlayer.setSourceUrl(audioUrl);

      // Remove loading dialog
      Navigator.pop(context);

      // Show audio player controls
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        enableDrag: true,
        isDismissible: true,
        builder: (context) => WillPopScope(
          onWillPop: () async {
            await _audioPlayer.stop();
            setState(() {
              _isPlaying = false;
            });
            return true;
          },
          child: NotificationListener<DraggableScrollableNotification>(
            onNotification: (notification) {
              if (notification.extent <= 0.0) {
                _audioPlayer.stop();
                setState(() {
                  _isPlaying = false;
                });
              }
              return true;
            },
            child: Container(
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
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Reciter info
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryColor.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
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
                            AppText(
                              reciter.name,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            const SizedBox(height: 4),
                            AppText(
                              '${moshaf.name} - ${surahs[selectedSurah]}',
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
                          _audioPlayer.stop();
                          setState(() {
                            _isPlaying = false;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Audio controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildControlButton(
                        icon: Icons.replay_10,
                        onPressed: () async {
                          try {
                            final position =
                                await _audioPlayer.getCurrentPosition();
                            if (position != null) {
                              final newPosition =
                                  position - const Duration(seconds: 10);
                              if (newPosition.inSeconds > 0) {
                                await _audioPlayer.seek(newPosition);
                              } else {
                                await _audioPlayer.seek(Duration.zero);
                              }
                            }
                          } catch (e) {
                            debugPrint('Error seeking backward: $e');
                          }
                        },
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 32,
                          ),
                          onPressed: () async {
                            try {
                              if (_isPlaying) {
                                await _audioPlayer.pause();
                              } else {
                                await _audioPlayer.resume();
                              }
                              setState(() {
                                _isPlaying = !_isPlaying;
                              });
                            } catch (e) {
                              debugPrint('Error toggling play state: $e');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: AppText(
                                    'حدث خطأ أثناء التحكم في التشغيل',
                                    color: Colors.white,
                                  ),
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 3),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      _buildControlButton(
                        icon: Icons.forward_10,
                        onPressed: () async {
                          try {
                            final position =
                                await _audioPlayer.getCurrentPosition();
                            final duration = await _audioPlayer.getDuration();
                            if (position != null && duration != null) {
                              final newPosition =
                                  position + const Duration(seconds: 10);
                              if (newPosition <= duration) {
                                await _audioPlayer.seek(newPosition);
                              } else {
                                await _audioPlayer.seek(duration);
                              }
                            }
                          } catch (e) {
                            debugPrint('Error seeking forward: $e');
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Progress bar
                  StreamBuilder<Duration?>(
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
                                    overlayShape:
                                        const RoundSliderOverlayShape(
                                          overlayRadius: 12,
                                        ),
                                    activeTrackColor: AppColors.primaryColor,
                                    inactiveTrackColor: Colors.grey[300],
                                    thumbColor: AppColors.primaryColor,
                                    overlayColor: AppColors.primaryColor
                                        .withOpacity(0.2),
                                  ),
                                  child: Slider(
                                    value: position.inSeconds
                                        .toDouble()
                                        .clamp(
                                          0.0,
                                          duration.inSeconds.toDouble(),
                                        ),
                                    max: duration.inSeconds.toDouble(),
                                    onChanged: (value) async {
                                      try {
                                        await _audioPlayer.seek(
                                          Duration(seconds: value.toInt()),
                                        );
                                      } catch (e) {
                                        debugPrint('Error seeking: $e');
                                      }
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      AppText(
                                        '${position.inMinutes}:${(position.inSeconds % 60).toString().padLeft(2, '0')}',
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                      AppText(
                                        '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
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
                                    if (state == PlayerState.playing) {
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
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Start playing
      await _audioPlayer.resume();
      setState(() {
        _isPlaying = true;
      });
    } catch (e) {
      debugPrint('Error playing recitation: $e');
      // Remove loading dialog
      Navigator.pop(context);

      // Show appropriate error message
      String errorMessage = 'حدث خطأ أثناء تحميل التلاوة';
      if (e.toString().contains('404')) {
        errorMessage = 'لم يتم العثور على التلاوة المطلوبة';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AppText(errorMessage, color: Colors.white),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.primaryColor, size: 24),
        onPressed: onPressed,
      ),
    );
  }

  void _showLanguageDialog() {
    final languages = {
      'ar': 'العربية',
      'eng': 'English',
      'fr': 'Français',
      'ru': 'Русский',
      'de': 'Deutsch',
      'es': 'Español',
      'tr': 'Türkçe',
    };

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const AppText(
              'اختر اللغة',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  languages.entries.map((entry) {
                    final isSelected = selectedLanguage == entry.key;
                    return ListTile(
                      title: AppText(
                        entry.value,
                        fontSize: 16,
                        color: isSelected ? AppColors.primaryColor : null,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      trailing:
                          isSelected
                              ? Icon(
                                Icons.check_circle,
                                color: AppColors.primaryColor,
                              )
                              : null,
                      onTap: () {
                        setState(() {
                          selectedLanguage = entry.key;
                        });
                        _loadReciters();
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
            ),
          ),
    );
  }

  void _showRewayaDialog() {
    final rewayas = {
      1: 'حفص عن عاصم',
      2: 'ورش عن نافع',
      3: 'قالون عن نافع',
      4: 'الدوري عن أبي عمرو',
      5: 'السوسي عن أبي عمرو',
      6: 'شعبة عن عاصم',
      7: 'ابن ذكوان عن ابن عامر',
      8: 'ابن كثير المكي',
      9: 'البزي عن ابن كثير',
      10: 'قنبل عن ابن كثير',
    };

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const AppText(
              'اختر الرواية',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const AppText('الكل'),
                  onTap: () {
                    setState(() {
                      selectedRewayaId = null;
                    });
                    _loadReciters();
                    Navigator.pop(context);
                  },
                ),
                ...rewayas.entries.map((entry) {
                  final isSelected = selectedRewayaId == entry.key;
                  return ListTile(
                    title: AppText(
                      entry.value,
                      fontSize: 16,
                      color: isSelected ? AppColors.primaryColor : null,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    trailing:
                        isSelected
                            ? Icon(
                              Icons.check_circle,
                              color: AppColors.primaryColor,
                            )
                            : null,
                    onTap: () {
                      setState(() {
                        selectedRewayaId = entry.key;
                      });
                      _loadReciters();
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ],
            ),
          ),
    );
  }

  void _showSuraDialog() {
    final suras = {
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
      // Add more surahs as needed
    };

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const AppText(
              'اختر السورة',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const AppText('الكل'),
                  onTap: () {
                    setState(() {
                      selectedSuraId = null;
                    });
                    _loadReciters();
                    Navigator.pop(context);
                  },
                ),
                ...suras.entries.map((entry) {
                  final isSelected = selectedSuraId == entry.key;
                  return ListTile(
                    title: AppText(
                      entry.value,
                      fontSize: 16,
                      color: isSelected ? AppColors.primaryColor : null,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    trailing:
                        isSelected
                            ? Icon(
                              Icons.check_circle,
                              color: AppColors.primaryColor,
                            )
                            : null,
                    onTap: () {
                      setState(() {
                        selectedSuraId = entry.key;
                      });
                      _loadReciters();
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ],
            ),
          ),
    );
  }

  @override
  void dispose() {
    try {
      _searchController.removeListener(() {});
      _searchController.dispose();
      _animationController.dispose();
      _audioPlayer.dispose();
    } catch (e) {
      debugPrint('Error disposing audio player: $e');
    }
    super.dispose();
  }
}
