import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serat/Business_Logic/Cubit/quran_cubit.dart';
import 'package:serat/Core/models/quran_chapter.dart';
import 'package:serat/Core/models/quran_verse.dart';
import 'package:serat/Core/services/quran_service.dart';
import 'package:serat/Core/services/cache_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuranChapterScreen extends StatefulWidget {
  final QuranChapter chapter;

  const QuranChapterScreen({super.key, required this.chapter});

  @override
  State<QuranChapterScreen> createState() => _QuranChapterScreenState();
}

class _QuranChapterScreenState extends State<QuranChapterScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  int _totalPages = 604;
  QuranService? _quranService;
  late final SharedPreferences _prefs;
  static const String _lastReadPagePrefix = 'last_read_page_';
  bool _isLoading = true;

  // Map of chapter numbers to their page ranges
  final Map<int, List<int>> _chapterPageRanges = {
    1: [1, 1],
    2: [2, 49],
    3: [50, 76],
    4: [77, 105],
    5: [106, 127],
    6: [128, 150],
    7: [151, 176],
    8: [177, 186],
    9: [187, 207],
    10: [208, 220],
    11: [221, 234],
    12: [235, 248],
    13: [249, 254],
    14: [255, 261],
    15: [262, 266],
    16: [267, 281],
    17: [282, 292],
    18: [293, 304],
    19: [305, 311],
    20: [312, 321],
    21: [322, 331],
    22: [332, 341],
    23: [342, 349],
    24: [350, 358],
    25: [359, 365],
    26: [366, 376],
    27: [377, 384],
    28: [385, 395],
    29: [396, 403],
    30: [404, 410],
    31: [411, 414],
    32: [415, 417],
    33: [418, 427],
    34: [428, 433],
    35: [434, 440],
    36: [440, 445],
    37: [446, 452],
    38: [453, 457],
    39: [458, 466],
    40: [467, 476],
    41: [477, 482],
    42: [483, 488],
    43: [489, 495],
    44: [496, 498],
    45: [499, 501],
    46: [502, 506],
    47: [507, 510],
    48: [511, 514],
    49: [515, 517],
    50: [518, 520],
    51: [520, 522],
    52: [523, 525],
    53: [526, 528],
    54: [528, 530],
    55: [531, 533],
    56: [534, 536],
    57: [537, 541],
    58: [542, 544],
    59: [545, 548],
    60: [549, 550],
    61: [551, 552],
    62: [553, 554],
    63: [554, 555],
    64: [556, 557],
    65: [558, 559],
    66: [560, 561],
    67: [562, 563],
    68: [564, 565],
    69: [566, 567],
    70: [568, 569],
    71: [570, 571],
    72: [572, 573],
    73: [574, 575],
    74: [575, 577],
    75: [577, 578],
    76: [578, 580],
    77: [580, 581],
    78: [582, 582],
    79: [583, 584],
    80: [585, 585],
    81: [586, 586],
    82: [587, 587],
    83: [587, 589],
    84: [589, 589],
    85: [590, 590],
    86: [591, 591],
    87: [591, 591],
    88: [592, 592],
    89: [593, 593],
    90: [594, 594],
    91: [595, 595],
    92: [595, 595],
    93: [596, 596],
    94: [596, 596],
    95: [597, 597],
    96: [597, 597],
    97: [598, 598],
    98: [598, 599],
    99: [599, 599],
    100: [599, 600],
    101: [600, 600],
    102: [601, 601],
    103: [601, 601],
    104: [601, 601],
    105: [602, 602],
    106: [602, 602],
    107: [602, 602],
    108: [603, 603],
    109: [603, 603],
    110: [603, 603],
    111: [604, 604],
    112: [604, 604],
    113: [604, 604],
    114: [604, 604],
  };

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _quranService = QuranService(CacheService(_prefs));
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showPageSelectionDialog();
      }
    } catch (e) {
      debugPrint('Error initializing services: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog();
      }
    }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('خطأ'),
          content: const Text(
              'حدث خطأ أثناء تحميل الصفحات. يرجى المحاولة مرة أخرى.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<QuranCubit>().returnToChapters();
              },
              child: const Text('العودة'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showPageSelectionDialog() async {
    final chapterNumber = widget.chapter.number;
    final pageRange = _chapterPageRanges[chapterNumber] ?? [1, 1];
    final lastReadPage = _prefs.getInt('$_lastReadPagePrefix$chapterNumber');

    if (lastReadPage != null &&
        lastReadPage >= pageRange[0] &&
        lastReadPage <= pageRange[1]) {
      if (!mounted) return;

      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          final isDarkMode = Theme.of(context).brightness == Brightness.dark;
          final primaryColor = Theme.of(context).primaryColor;

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.menu_book_rounded,
                      size: 40,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'سورة ${widget.chapter.name['ar'] ?? ''}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'آخر صفحة تمت قراءتها: ${_toArabicNumbers(lastReadPage.toString())}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.of(context).pop(false),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text(
                            'بداية السورة',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 16,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDarkMode
                                ? Colors.grey[800]
                                : Colors.grey[200],
                            foregroundColor:
                                isDarkMode ? Colors.white : Colors.black87,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.of(context).pop(true),
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text(
                            'الاستمرار',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 16,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );

      if (result != null) {
        _initializePage(continueFromLast: result);
      }
    } else {
      _initializePage(continueFromLast: false);
    }
  }

  Future<void> _initializePage({required bool continueFromLast}) async {
    try {
      final chapterNumber = widget.chapter.number;
      final pageRange = _chapterPageRanges[chapterNumber];
      if (pageRange != null && mounted) {
        int startPage;
        if (continueFromLast) {
          final lastReadPage =
              _prefs.getInt('$_lastReadPagePrefix$chapterNumber') ??
                  pageRange[0];
          startPage = lastReadPage;
        } else {
          startPage = pageRange[0];
        }

        setState(() {
          _currentPage = startPage -
              pageRange[
                  0]; // Convert to 0-based index relative to chapter start
        });
        _pageController.jumpToPage(_currentPage);
      }
    } catch (e) {
      debugPrint('Error initializing page: $e');
    }
  }

  void _saveCurrentPage() {
    final chapterNumber = widget.chapter.number;
    final pageRange = _chapterPageRanges[chapterNumber];
    if (pageRange != null) {
      final actualPageNumber = pageRange[0] + _currentPage;
      _prefs.setInt('$_lastReadPagePrefix$chapterNumber', actualPageNumber);
    }
  }

  @override
  void dispose() {
    _saveCurrentPage();
    _pageController.dispose();
    super.dispose();
  }

  String _toArabicNumbers(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    for (int i = 0; i < english.length; i++) {
      input = input.replaceAll(english[i], arabic[i]);
    }
    return input;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBgColor = isDarkMode ? Colors.black : Colors.grey[50];
    final appBarColor = Theme.of(context).primaryColor;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: scaffoldBgColor,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_quranService == null) {
      return Scaffold(
        backgroundColor: scaffoldBgColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'حدث خطأ في تحميل الصفحات',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  context.read<QuranCubit>().returnToChapters();
                },
                child: const Text('العودة إلى السور'),
              ),
            ],
          ),
        ),
      );
    }

    // Get the page range for current chapter
    final pageRange = _chapterPageRanges[widget.chapter.number] ?? [1, 1];
    final chapterStartPage = pageRange[0];
    final chapterEndPage = pageRange[1];
    final chapterPageCount = chapterEndPage - chapterStartPage + 1;

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop) {
          _saveCurrentPage();
          context.read<QuranCubit>().returnToChapters();
        }
      },
      child: Scaffold(
        backgroundColor: scaffoldBgColor,
        appBar: AppBar(
          backgroundColor: appBarColor,
          elevation: isDarkMode ? 0.5 : 1.0,
          scrolledUnderElevation: 2.0,
          centerTitle: true,
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "سورة ${widget.chapter.name['ar'] ?? ''}",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.white,
                  fontFamily: 'Amiri',
                ),
              ),
              AnimatedOpacity(
                opacity: chapterPageCount > 0 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Text(
                  '${_toArabicNumbers((_currentPage + 1).toString())} / ${_toArabicNumbers(chapterPageCount.toString())}',
                  style: TextStyle(
                    color: (isDarkMode ? Colors.white : Colors.white)
                        .withAlpha(200),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 22),
            color: isDarkMode ? Colors.white : Colors.white,
            tooltip: 'Back to Chapters',
            onPressed: () {
              _saveCurrentPage();
              context.read<QuranCubit>().returnToChapters();
              Navigator.of(context).pop();
            },
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return PageView.builder(
              controller: _pageController,
              itemCount: chapterPageCount,
              onPageChanged: (page) {
                if (mounted) {
                  setState(() => _currentPage = page);
                  _saveCurrentPage();
                }
              },
              itemBuilder: (context, pageIndex) {
                final actualPageNumber = chapterStartPage + pageIndex;
                return Center(
                  child: Image.asset(
                    _quranService!.getPageImagePath(actualPageNumber),
                    fit: BoxFit.contain,
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
