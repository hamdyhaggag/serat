import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serat/Business_Logic/Cubit/quran_cubit.dart';
import 'package:serat/Core/models/quran_chapter.dart';
import 'package:serat/Core/models/quran_verse.dart'; // Ensure this path is correct

class QuranChapterScreen extends StatefulWidget {
  final QuranChapter chapter;

  const QuranChapterScreen({super.key, required this.chapter});

  @override
  State<QuranChapterScreen> createState() => _QuranChapterScreenState();
}

class _QuranChapterScreenState extends State<QuranChapterScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _versesPerPage = 10; // Consider making this configurable or dynamic

  List<List<QuranVerse>> _pagedVerses = [];
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<QuranCubit>().getChapterVerses(widget.chapter.number);
      }
    });
  }

  void _paginateVerses(List<QuranVerse> allVerses) {
    _pagedVerses = [];
    if (allVerses.isEmpty) {
      _totalPages = 0;
      if (mounted) setState(() {});
      return;
    }

    List<QuranVerse> versesToPaginate = List.from(allVerses);

    if (widget.chapter.number != 9 && widget.chapter.number != 1) {
      final bismillahVerse = QuranVerse(
          text: {
            'ar': 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ'
          },
          number: 0, // Special identifier for Bismillah
          // Ensure these match your QuranVerse model's requirements for non-nullable fields
          // If your model has an 'id', ensure it's provided or nullable.
          juz: widget.chapter.verses.isNotEmpty
              ? widget.chapter.verses.first.juz
              : 0,
          page: widget.chapter.verses.isNotEmpty
              ? widget.chapter.verses.first.page
              : 0,
          sajda: null);
      versesToPaginate.insert(0, bismillahVerse);
    }

    for (int i = 0; i < versesToPaginate.length; i += _versesPerPage) {
      _pagedVerses.add(
        versesToPaginate.sublist(
            i,
            i + _versesPerPage > versesToPaginate.length
                ? versesToPaginate.length
                : i + _versesPerPage),
      );
    }

    if (_pagedVerses.isEmpty && versesToPaginate.isNotEmpty) {
      _pagedVerses.add(versesToPaginate);
      _totalPages = 1;
    } else if (_pagedVerses.isEmpty) {
      _totalPages = 0;
    } else {
      _totalPages = _pagedVerses.length;
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _toArabicNumbers(String number) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    for (int i = 0; i < english.length; i++) {
      number = number.replaceAll(english[i], arabic[i]);
    }
    return number;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Professional Color Palette
    final primaryColor = theme.primaryColor; // Keep primary color from theme
    final scaffoldBgColor = isDarkMode
        ? const Color(0xFF121212)
        : const Color(0xFFF0F2F5); // Slightly off-white/grey
    final appBarColor = isDarkMode ? const Color(0xFF1E1E1E) : primaryColor;
    final pageColor = isDarkMode
        ? const Color(0xFF1E1E1E)
        : const Color(0xFFFFFFFF); // White page for light, dark grey for dark
    final mainTextColor =
        isDarkMode ? const Color(0xFFE0E0E0) : const Color(0xFF1B2028);
    final subtleTextColor = isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;
    final pageBorderColor =
        isDarkMode ? Colors.grey[700]!.withAlpha(100) : Colors.grey[300]!;
    final shadowColor =
        isDarkMode ? Colors.black.withAlpha(100) : Colors.grey.withAlpha(70);

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop) {
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
                  fontSize: 22, // Adjusted for better balance
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.white,
                  fontFamily: 'Amiri',
                ),
              ),
              if (_totalPages > 0)
                AnimatedOpacity(
                  opacity: _totalPages > 0 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    '${_toArabicNumbers((_currentPage + 1).toString())} / ${_toArabicNumbers(_totalPages.toString())}',
                    style: TextStyle(
                      color: (isDarkMode ? Colors.white : Colors.white)
                          .withAlpha(200),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Cairo', // Consistent font
                    ),
                  ),
                ),
            ],
          ),
          leading: Center(
            // Ensures button is centered in its space
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 22),
              color: isDarkMode ? Colors.white : Colors.white,
              tooltip: 'Back to Chapters',
              onPressed: () {
                context.read<QuranCubit>().returnToChapters();
                Navigator.of(context).pop();
              },
            ),
          ),
          // Consider adding actions like settings or bookmarks later
        ),
        body: BlocConsumer<QuranCubit, QuranState>(
          listener: (context, state) {
            if (state is QuranVersesLoaded) {
              _paginateVerses(state.verses);
              if (_pageController.hasClients && _pageController.page != 0.0) {
                _pageController.jumpToPage(0);
              }
              _currentPage = 0;
            } else if (state is QuranInitial) {
              if (mounted && widget.chapter.number > 0) {
                context
                    .read<QuranCubit>()
                    .getChapterVerses(widget.chapter.number);
              }
            }
          },
          builder: (context, state) {
            if (state is QuranVersesLoading ||
                (state is QuranInitial && widget.chapter.number > 0)) {
              return Center(
                  child: CircularProgressIndicator(color: primaryColor));
            } else if (state is QuranVersesError) {
              return _buildErrorState(context, state.message, primaryColor);
            } else if (state is QuranVersesLoaded) {
              if (_pagedVerses.isEmpty) {
                return _buildEmptyState(mainTextColor);
              }
              return Column(
                children: [
                  if (_currentPage == 0) // Show header only on the first page
                    _buildSurahPageHeader(context, isDarkMode, primaryColor,
                        mainTextColor, subtleTextColor, pageColor, shadowColor),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _totalPages,
                      // reverse: true, // RTL page turning if desired
                      onPageChanged: (page) {
                        if (mounted) setState(() => _currentPage = page);
                      },
                      itemBuilder: (context, pageIndex) {
                        final pageVerses = _pagedVerses[pageIndex];
                        return _buildMushafPage(
                          context,
                          pageVerses,
                          pageIndex,
                          _totalPages,
                          widget.chapter,
                          mainTextColor,
                          pageColor,
                          pageBorderColor,
                          primaryColor,
                          shadowColor,
                          subtleTextColor,
                        );
                      },
                    ),
                  ),
                ],
              );
            }
            return _buildEmptyState(mainTextColor, message: "يرجى تحديد سورة");
          },
        ),
      ),
    );
  }

  Widget _buildErrorState(
      BuildContext context, String message, Color primaryColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.red[400], size: 60),
            const SizedBox(height: 20),
            Text(
              'حدث خطأ',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyMedium?.color),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة',
                  style: TextStyle(
                      fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
              onPressed: () {
                context
                    .read<QuranCubit>()
                    .getChapterVerses(widget.chapter.number);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color textColor,
      {String message = 'لا توجد آيات لعرضها'}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book_rounded,
              size: 80, color: textColor.withAlpha(100)),
          const SizedBox(height: 20),
          Text(
            message,
            style: TextStyle(
                fontSize: 18,
                fontFamily: 'Amiri',
                color: textColor.withAlpha(150)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSurahPageHeader(
      BuildContext context,
      bool isDarkMode,
      Color primaryColor,
      Color mainTextColor,
      Color subtleTextColor,
      Color headerBgColor,
      Color shadowColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
      margin: const EdgeInsets.only(top: 12.0, left: 12, right: 12, bottom: 0),
      decoration: BoxDecoration(
          color:
              headerBgColor, // Use the general page color or a slightly different tint
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
                color: shadowColor, blurRadius: 10, offset: const Offset(0, 2)),
          ],
          border: Border.all(
              color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
              width: 0.5)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "سورة ${widget.chapter.name['ar'] ?? ''}",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 30, // Prominent Surah name
              fontWeight: FontWeight.bold,
              color: primaryColor, // Use primary color for Surah name
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: primaryColor.withAlpha(
                  isDarkMode ? 40 : 25), // Subtle background for info
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              // Ensure revelationPlace and versesCount exist and are valid on QuranChapter model
              "${widget.chapter.revelationPlace == 'Meccan' ? 'مكية' : 'مدنية'} • ${_toArabicNumbers(widget.chapter.versesCount.toString())} آيات",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: primaryColor.withAlpha(200),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMushafPage(
    BuildContext context,
    List<QuranVerse> verses,
    int pageIndex,
    int totalPages,
    QuranChapter chapter,
    Color mainTextColor,
    Color pageBackgroundColor,
    Color pageBorderColor,
    Color primaryColor,
    Color shadowColor,
    Color subtleTextColor,
  ) {
    final bool isFirstPageWithHeader = pageIndex == 0;

    return Container(
      margin: EdgeInsets.only(
          left: 12.0,
          right: 12.0,
          bottom: 16.0,
          top: (isFirstPageWithHeader
              ? 0
              : 12.0) // No top margin if header is shown directly above
          ),
      padding: const EdgeInsets.symmetric(
          horizontal: 16.0, vertical: 20.0), // Increased padding
      decoration: BoxDecoration(
        color: pageBackgroundColor,
        border:
            Border.all(color: pageBorderColor, width: 1.0), // Thinner border
        borderRadius: isFirstPageWithHeader
            ? const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16))
            : BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
              color: shadowColor, blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Bismillah display
            if (pageIndex == 0 &&
                verses.isNotEmpty &&
                verses.first.number == 0 && // Is Bismillah pseudo-verse
                chapter.number != 1 && // Not Fatiha (Bismillah is part of it)
                chapter.number != 9) // Not Tawbah (No Bismillah)
              Container(
                margin: const EdgeInsets.only(bottom: 20.0, top: 4.0),
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: primaryColor.withAlpha(70), width: 1.0))),
                child: Text(
                  verses.first.text['ar']!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily:
                        'Amiri', // Consider a specific Bismillah font if available
                    fontSize: 22, // Prominent Bismillah
                    fontWeight: FontWeight.w500,
                    color: mainTextColor,
                    height: 1.8,
                  ),
                ),
              ),
            // Verses display
            RichText(
              textAlign: TextAlign.justify, // Justified text for Mushaf feel
              textDirection: TextDirection.rtl,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 23, // Slightly adjusted font size for body
                  color: mainTextColor,
                  fontFamily: 'Amiri',
                  height: 2.5, // Generous line height for readability
                  letterSpacing: 0.3,
                  fontWeight: FontWeight.normal, // Standard weight for reading
                ),
                children: verses.expand((verse) {
                  // Skip Bismillah if it was the pseudo-verse and handled above
                  if (pageIndex == 0 &&
                      verse.number == 0 &&
                      chapter.number != 1 &&
                      chapter.number != 9) {
                    return <InlineSpan>[];
                  }

                  return <InlineSpan>[
                    TextSpan(
                        text:
                            "${verse.text['ar']?.toString() ?? ''} "), // Add space after verse
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      baseline: TextBaseline.alphabetic,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: primaryColor.withAlpha(100), width: 1.0),
                          shape: BoxShape.circle,
                          // color: primaryColor.withAlpha(30), // Optional: very subtle background
                        ),
                        child: Text(
                          _toArabicNumbers(verse.number.toString()),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600, // Bolder for number
                            color:
                                primaryColor, // Use primary color for verse numbers
                            fontFamily: 'Cairo', // Numeric font
                          ),
                        ),
                      ),
                    ),
                    if (verse.sajda?.obligatory == true)
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Icon(
                            Icons
                                .star_border_purple500_outlined, // More distinct Sajda icon
                            color: Colors.green.shade600,
                            size: 20,
                          ),
                        ),
                      ),
                  ];
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
