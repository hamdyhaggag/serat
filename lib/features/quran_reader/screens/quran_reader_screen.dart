/// Professional Quran Reader Screen
/// Provides an immersive reading experience inspired by Madinah Mushaf

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:serat/Core/models/quran_chapter.dart';
import 'package:serat/Presentation/Config/constants/colors.dart';
import '../data/quran_page_data.dart';
import '../theme/quran_reader_theme.dart';
import '../services/quran_page_service.dart';
import '../widgets/quran_page_widget.dart';
import '../widgets/reading_controls.dart';
import 'package:serat/Presentation/Widgets/share_verse_generator.dart';

class QuranReaderScreen extends StatefulWidget {
  final int initialPage;
  final int? initialSurah;

  const QuranReaderScreen({
    super.key,
    this.initialPage = 1,
    this.initialSurah,
  });

  @override
  State<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends State<QuranReaderScreen>
    with TickerProviderStateMixin {
  // Services
  final QuranPageService _pageService = QuranPageService();

  // Controllers
  late PageController _pageController;
  late AnimationController _fadeController;

  // State
  int _currentPage = 1;
  double _fontSize = QuranTypography.defaultFontSize;
  QuranReaderTheme _currentTheme = QuranReaderTheme.light;
  bool _isLoading = true;
  bool _showControls = false;
  bool _isFullScreen = false;
  QuranPageData? _currentPageData;
  List<QuranChapter> _chapters = [];
  Set<int> _bookmarkedPages = {};

  // Preferences keys
  static const String _fontSizeKey = 'quran_reader_font_size';
  static const String _themeKey = 'quran_reader_theme';
  static const String _lastPageKey = 'quran_reader_last_page';
  static const String _bookmarksKey = 'quran_reader_bookmarks';

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialPage - 1);
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _currentPage = widget.initialPage;
    _initializeReader();
  }

  Future<void> _initializeReader() async {
    await _loadPreferences();
    await _loadChapters();

    if (widget.initialSurah != null) {
      final startPage =
          await _pageService.getSurahStartPage(widget.initialSurah!);
      _currentPage = startPage;
      _pageController = PageController(initialPage: startPage - 1);
    }

    await _loadCurrentPage();
    _preloadAdjacentPages();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      _fadeController.forward();
    }
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fontSize =
          prefs.getDouble(_fontSizeKey) ?? QuranTypography.defaultFontSize;
      final themeIndex = prefs.getInt(_themeKey) ?? 0;
      _currentTheme = QuranReaderTheme.values[themeIndex];

      // Load bookmarks
      final bookmarksJson = prefs.getStringList(_bookmarksKey) ?? [];
      _bookmarkedPages = bookmarksJson.map((e) => int.tryParse(e) ?? 0).toSet();
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, _fontSize);
    await prefs.setInt(_themeKey, _currentTheme.index);
    await prefs.setInt(_lastPageKey, _currentPage);
    await prefs.setStringList(
      _bookmarksKey,
      _bookmarkedPages.map((e) => e.toString()).toList(),
    );
  }

  Future<void> _loadChapters() async {
    _chapters = await _pageService.loadChapters();
  }

  Future<void> _loadCurrentPage() async {
    final pageData = await _pageService.getPageData(_currentPage);
    if (mounted) {
      setState(() {
        _currentPageData = pageData;
      });
    }
  }

  void _preloadAdjacentPages() {
    _pageService.preloadPages(_currentPage, range: 3);
  }

  void _onPageChanged(int pageIndex) {
    setState(() {
      _currentPage = pageIndex + 1;
    });
    _loadCurrentPage();
    _preloadAdjacentPages();
    _savePreferences();
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });

    if (_showControls) {
      // Show system UI when controls are visible
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    } else if (_isFullScreen) {
      // Hide system UI for immersive reading
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });

    if (_isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReadingControlsSheet(
        fontSize: _fontSize,
        currentTheme: _currentTheme,
        currentPage: _currentPage,
        totalPages: _pageService.totalPages,
        isBookmarked: _bookmarkedPages.contains(_currentPage),
        onFontSizeChanged: (size) {
          setState(() {
            _fontSize = size;
          });
          _savePreferences();
        },
        onThemeChanged: (theme) {
          setState(() {
            _currentTheme = theme;
          });
          Navigator.pop(context);
          _savePreferences();
        },
        onPageJump: (page) {
          _pageController.jumpToPage(page - 1);
          Navigator.pop(context);
        },
        onBookmark: () {
          _toggleBookmark();
        },
      ),
    );
  }

  void _toggleBookmark() {
    setState(() {
      if (_bookmarkedPages.contains(_currentPage)) {
        _bookmarkedPages.remove(_currentPage);
      } else {
        _bookmarkedPages.add(_currentPage);
      }
    });
    _savePreferences();

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _bookmarkedPages.contains(_currentPage)
              ? 'تم حفظ العلامة المرجعية'
              : 'تم إزالة العلامة المرجعية',
          style: const TextStyle(fontFamily: 'DIN'),
        ),
        backgroundColor: AppColors.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showSurahList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildSurahListSheet(),
    );
  }

  Widget _buildSurahListSheet() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'قائمة السور',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'DIN',
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ),
          // Surah list
          Expanded(
            child: ListView.builder(
              itemCount: _chapters.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final chapter = _chapters[index];
                return ListTile(
                  onTap: () async {
                    Navigator.pop(context);
                    final startPage =
                        await _pageService.getSurahStartPage(chapter.number);
                    _pageController.jumpToPage(startPage - 1);
                  },
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        ArabicNumbers.convert(chapter.number),
                        style: TextStyle(
                          fontFamily: 'DIN',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    chapter.name['ar'] ?? '',
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 18,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    '${chapter.name['en']} • ${ArabicNumbers.convert(chapter.versesCount)} آية',
                    style: TextStyle(
                      fontFamily: 'DIN',
                      fontSize: 12,
                      color: isDarkMode ? Colors.white60 : Colors.black54,
                    ),
                  ),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: chapter.revelationPlace['en'] == 'meccan'
                          ? Colors.orange.withValues(alpha: 0.1)
                          : Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      chapter.revelationPlace['ar'] ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'DIN',
                        color: chapter.revelationPlace['en'] == 'meccan'
                            ? Colors.orange
                            : Colors.blue,
                      ),
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

  String _getPrimarySurahName() {
    if (_currentPageData == null || _currentPageData!.surahsOnPage.isEmpty) {
      return '';
    }
    final surahNumber = _currentPageData!.surahsOnPage.first;
    return _pageService.getSurahName(surahNumber);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _savePreferences();
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = QuranReaderColors.getTheme(_currentTheme);

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child:
            _isLoading ? _buildLoadingState(theme) : _buildReaderContent(theme),
      ),
    );
  }

  Widget _buildLoadingState(QuranThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              color: theme.frameColor,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'جارٍ تحميل المصحف...',
            style: QuranTypography.headerTextStyle(
              color: theme.textColor,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReaderContent(QuranThemeData theme) {
    return Stack(
      children: [
        // Main page view
        GestureDetector(
          onTap: _toggleControls,
          child: FadeTransition(
            opacity: _fadeController,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pageService.totalPages,
                // No reverse needed - Directionality handles RTL
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  // Page numbers are 1-indexed
                  final pageNumber = index + 1;
                  return FutureBuilder<QuranPageData>(
                    future: _pageService.getPageData(pageNumber),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: theme.frameColor,
                          ),
                        );
                      }

                      return QuranPageWidget(
                        pageData: snapshot.data!,
                        theme: theme,
                        fontSize: _fontSize,
                        primarySurahName:
                            snapshot.data!.getPrimarySurahName(_chapters),
                        onVerseLongPress: (verse) {
                          HapticFeedback.mediumImpact();
                          ShareVerseGenerator.show(
                            context,
                            verseText: verse.arabicText,
                            shareText: verse.arabicText,
                            surahName: verse.surahName,
                            verseNumber: verse.verseNumber,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),

        // Top bar (when controls are visible)
        if (_showControls)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            _getPrimarySurahName(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontFamily: 'Amiri',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'صفحة ${ArabicNumbers.convert(_currentPage)}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontFamily: 'DIN',
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _toggleFullScreen,
                      icon: Icon(
                        _isFullScreen
                            ? Icons.fullscreen_exit
                            : Icons.fullscreen,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Floating controls (when controls are visible)
        QuranFloatingControls(
          showControls: _showControls,
          onSettingsPressed: _showSettingsSheet,
          onPlayPressed: () {
            // TODO: Implement audio playback
          },
          onBookmarkPressed: _toggleBookmark,
          onSurahListPressed: _showSurahList,
        ),
      ],
    );
  }
}
