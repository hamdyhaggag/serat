import 'package:flutter/material.dart';
import 'package:serat/Business_Logic/Cubit/reciters_cubit.dart';
import 'package:serat/Business_Logic/Cubit/download_cubit.dart';
import 'package:serat/Business_Logic/Models/reciter_model.dart';
import 'package:serat/Business_Logic/Models/download_model.dart';
import 'package:serat/Data/services/audio_player_service.dart';
import 'package:serat/imports.dart';
import 'package:serat/Presentation/Widgets/reciters/download_manager_widget.dart';
import 'package:serat/Presentation/Widgets/reciters/audio_player_widget.dart';
import 'package:serat/Presentation/Widgets/reciters/reciter_card_widget.dart';
import 'package:serat/Presentation/Widgets/reciters/search_bar_widget.dart';
import 'package:serat/Presentation/Widgets/reciters/error_view_widget.dart';

class RecitersScreenRefactored extends StatefulWidget {
  const RecitersScreenRefactored({super.key});

  @override
  State<RecitersScreenRefactored> createState() =>
      _RecitersScreenRefactoredState();
}

class _RecitersScreenRefactoredState extends State<RecitersScreenRefactored>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  List<Reciter> _filteredReciters = [];
  final AudioPlayerService _audioPlayerService = AudioPlayerService();
  bool _isOfflineMode = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _setupAnimation();
    _setupSearchListener();
    _loadReciters();
  }

  Future<void> _initializeServices() async {
    try {
      await _audioPlayerService.initialize();
      if (mounted) {
        await DownloadCubit.get(context).initialize();
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('فشل في تهيئة الخدمات');
      }
    }
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();
  }

  void _setupSearchListener() {
    _searchController.addListener(() {
      _filterReciters(_searchController.text);
    });
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
              .where((reciter) =>
                  reciter.name.toLowerCase().contains(query.toLowerCase()) ||
                  reciter.letter.toLowerCase().contains(query.toLowerCase()))
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
            SearchBarWidget(
              controller: _searchController,
              isDarkMode: isDarkMode,
              onChanged: _filterReciters,
            ),
            Expanded(child: _buildBody(isDarkMode)),
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
                color: Colors.orange.withValues(alpha: 0.2),
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
                    const Color.fromRGBO(0, 150, 136, 0.8)
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
          icon: const Icon(Icons.download, color: Colors.white),
          onPressed: () => _showDownloadManager(),
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () {
            setState(() => _isOfflineMode = false);
            RecitersCubit.get(context).getReciters(forceRefresh: true);
          },
        ),
      ],
    );
  }

  Widget _buildBody(bool isDarkMode) {
    return BlocBuilder<RecitersCubit, RecitersState>(
      builder: (context, state) {
        if (state is RecitersLoading && !_isOfflineMode) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is RecitersError && !_isOfflineMode) {
          return ErrorViewWidget(
            error: RecitersCubit.get(context).error ?? 'حدث خطأ غير معروف',
            onRetry: () {
              setState(() => _isOfflineMode = false);
              _loadReciters();
            },
          );
        }

        final cubit = RecitersCubit.get(context);
        if (cubit.recitersModel?.reciters.isEmpty ?? true) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _filteredReciters.length,
          itemBuilder: (context, index) {
            final reciter = _filteredReciters[index];
            return ReciterCardWidget(
              reciter: reciter,
              isDarkMode: isDarkMode,
              onTap: () => _showReciterDetails(reciter),
              onDownloadMoshaf: (moshaf) => _showDownloadOptions(reciter, moshaf),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
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
                RecitersCubit.get(context).getReciters(forceRefresh: true);
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

  void _showReciterDetails(Reciter reciter) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReciterDetailsSheet(
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

  void _playRecitation(Reciter reciter, Moshaf moshaf) async {
    final selectedSurah = await _showSurahSelectionDialog();
    if (selectedSurah == null) return;

    try {
      await _audioPlayerService.playRecitation(
        reciter: reciter,
        moshaf: moshaf,
        surahNumber: selectedSurah,
      );

      _showAudioPlayer(reciter, moshaf, selectedSurah);
    } catch (e) {
      _showErrorSnackBar('فشل في تشغيل التلاوة');
    }
  }

  void _showDownloadOptions(Reciter reciter, Moshaf moshaf) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => DownloadOptionsSheet(
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
  }

  void _showDownloadManager() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const DownloadManagerWidget(),
    );
  }

  void _showAudioPlayer(Reciter reciter, Moshaf moshaf, int selectedSurah) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isDismissible: true,
      builder: (context) => AudioPlayerWidget(
        reciter: reciter,
        moshaf: moshaf,
        selectedSurah: selectedSurah,
        audioPlayerService: _audioPlayerService,
      ),
    );
  }

  Future<int?> _showSurahSelectionDialog() async {
    final surahs = _getSurahList();

    return showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
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

  Map<int, String> _getSurahList() {
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

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}

// Additional widget classes will be created in separate files
class ReciterDetailsSheet extends StatelessWidget {
  final Reciter reciter;
  final Function(Moshaf) onPlay;
  final Function(Moshaf) onDownload;

  const ReciterDetailsSheet({
    super.key,
    required this.reciter,
    required this.onPlay,
    required this.onDownload,
  });

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
                return MoshafListItem(
                  moshaf: moshaf,
                  onPlay: () => onPlay(moshaf),
                  onDownload: () => onDownload(moshaf),
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

class MoshafListItem extends StatelessWidget {
  final Moshaf moshaf;
  final VoidCallback onPlay;
  final VoidCallback onDownload;

  const MoshafListItem({
    super.key,
    required this.moshaf,
    required this.onPlay,
    required this.onDownload,
  });

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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: onDownload,
            ),
            IconButton(
              icon: const Icon(Icons.play_circle_outline),
              onPressed: onPlay,
            ),
          ],
        ),
      ),
    );
  }
}

class DownloadOptionsSheet extends StatelessWidget {
  final Reciter reciter;
  final Moshaf moshaf;
  final Function(int) onDownloadSurah;
  final Function(List<int>) onDownloadMultiple;

  const DownloadOptionsSheet({
    super.key,
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
          AppText(
            'خيارات التحميل',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 20),
          ListTile(
            leading:  Icon(Icons.download, color: AppColors.primaryColor),
            title: const AppText('تحميل سورة واحدة'),
            onTap: () => _showSurahSelection(context),
          ),
          ListTile(
            leading:
                 Icon(Icons.download_done, color: AppColors.primaryColor),
            title: const AppText('تحميل عدة سور'),
            onTap: () => _showMultipleSurahSelection(context),
          ),
          ListTile(
            leading:  Icon(Icons.download_for_offline,
                color: AppColors.primaryColor),
            title: const AppText('تحميل جميع السور'),
            onTap: () => _downloadAllSurahs(context),
          ),
        ],
      ),
    );
  }

  void _showSurahSelection(BuildContext context) {
    // Implementation for single surah selection
  }

  void _showMultipleSurahSelection(BuildContext context) {
    // Implementation for multiple surah selection
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
}
