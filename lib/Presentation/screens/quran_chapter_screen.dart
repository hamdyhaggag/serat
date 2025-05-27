import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serat/Business_Logic/Cubit/quran_cubit.dart';
import 'package:serat/Core/models/quran_chapter.dart';
import 'package:serat/Core/models/quran_verse.dart';

class QuranChapterScreen extends StatefulWidget {
  final QuranChapter chapter;

  const QuranChapterScreen({super.key, required this.chapter});

  @override
  State<QuranChapterScreen> createState() => _QuranChapterScreenState();
}

class _QuranChapterScreenState extends State<QuranChapterScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _versesPerPage = 10;

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
      setState(() {});
      return;
    }

    List<QuranVerse> versesToPaginate = List.from(allVerses);

    if (widget.chapter.number != 9 && widget.chapter.number != 1) {
      final bismillahVerse = QuranVerse(
          text: {'ar': 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ'},
          number: 0,
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
    setState(() {});
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF2C3E50);
    final mushafPageColor =
        isDarkMode ? Colors.grey[900] ?? Colors.grey : const Color(0xFFFBF0D9);
    final borderColor = isDarkMode
        ? Colors.grey[700] ?? Colors.grey[600]!
        : Theme.of(context).primaryColor.withAlpha((0.5 * 255).round());
    final primaryColor = Theme.of(context).primaryColor;

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop) {
          context.read<QuranCubit>().returnToChapters();
        }
      },
      child: Scaffold(
        backgroundColor: isDarkMode ? Colors.black : const Color(0xFFEFE0CC),
        appBar: AppBar(
          backgroundColor:
              isDarkMode ? Colors.grey[900] ?? Colors.black : primaryColor,
          elevation: 1,
          title: Text(
            "سورة ${widget.chapter.name['ar'] ?? ''}",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Amiri',
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              context.read<QuranCubit>().returnToChapters();
              Navigator.of(context).pop();
            },
          ),
          actions: [
            if (_totalPages > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(
                  child: Text(
                    '${_currentPage + 1} / $_totalPages',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
          ],
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
                child: CircularProgressIndicator(color: primaryColor),
              );
            } else if (state is QuranVersesError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'حدث خطأ: ${state.message}',
                      style: TextStyle(fontSize: 16, color: Colors.red[700]),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context
                            .read<QuranCubit>()
                            .getChapterVerses(widget.chapter.number);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('إعادة المحاولة',
                          style: TextStyle(fontFamily: 'Cairo')),
                    ),
                  ],
                ),
              );
            } else if (state is QuranVersesLoaded) {
              if (_pagedVerses.isEmpty) {
                return const Center(
                  child: Text(
                    'لا توجد آيات لعرضها',
                    style: TextStyle(fontSize: 18, fontFamily: 'Amiri'),
                  ),
                );
              }
              return Column(
                children: [
                  if (_currentPage == 0)
                    _buildSurahPageHeader(context, isDarkMode, primaryColor),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _totalPages,
                      onPageChanged: (page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      itemBuilder: (context, pageIndex) {
                        final pageVerses = _pagedVerses[pageIndex];
                        return _buildMushafPage(
                          context,
                          pageVerses,
                          pageIndex,
                          _totalPages,
                          widget.chapter,
                          textColor,
                          mushafPageColor,
                          borderColor,
                          primaryColor,
                        );
                      },
                    ),
                  ),
                ],
              );
            }
            return Center(
              child: Text("يرجى تحديد سورة",
                  style: TextStyle(
                      fontFamily: 'Amiri', fontSize: 18, color: textColor)),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSurahPageHeader(
      BuildContext context, bool isDarkMode, Color primaryColor) {
    final headerBackgroundColor = isDarkMode
        ? Colors.grey[800] ?? Colors.grey
        : primaryColor.withAlpha((0.1 * 255).round());
    final headerBorderColor =
        isDarkMode ? primaryColor.withAlpha((0.5 * 255).round()) : primaryColor;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      margin: const EdgeInsets.only(top: 8.0, left: 16, right: 16, bottom: 0),
      decoration: BoxDecoration(
          color: headerBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          border: Border.all(color: headerBorderColor, width: 1.5)),
      child: Column(
        children: [
          Text(
            "سورة ${widget.chapter.name['ar'] ?? ''}",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDarkMode
                  ? Colors.white
                  : Theme.of(context).primaryColorDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "${widget.chapter.revelationPlace == 'Meccan' ? 'مكية' : 'مدنية'} - ${widget.chapter.versesCount} آيات",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: isDarkMode ? Colors.grey[300] : Colors.black54,
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
    Color textColor,
    Color pageBackgroundColorForMethod,
    Color borderColorForMethod,
    Color primaryColorForMethod,
  ) {
    return Container(
      margin: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          bottom: 16.0,
          top: (pageIndex == 0 && _totalPages > 0 ? 0 : 8.0)),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: pageBackgroundColorForMethod,
        border: Border.all(
          color: borderColorForMethod,
          width: 2.0,
        ),
        borderRadius: pageIndex == 0 && _totalPages > 0
            ? const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12))
            : BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (pageIndex == 0 &&
                verses.isNotEmpty &&
                verses.first.number == 0 &&
                chapter.number != 1 &&
                chapter.number != 9)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  verses.first.text['ar']!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    height: 1.8,
                  ),
                ),
              ),
            RichText(
              textAlign: TextAlign.justify,
              textDirection: TextDirection.rtl,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 22,
                  color: textColor,
                  fontFamily: 'Amiri',
                  height: 2.2,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w500,
                ),
                children: verses.expand((verse) {
                  if (pageIndex == 0 &&
                      verse.number == 0 &&
                      chapter.number != 1 &&
                      chapter.number != 9) return <InlineSpan>[];

                  return <InlineSpan>[
                    TextSpan(text: verse.text['ar']?.toString() ?? ''),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6.0),
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: primaryColorForMethod
                                  .withAlpha((0.7 * 255).round()),
                              width: 1.5),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          _toArabicNumbers(verse.number.toString()),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: primaryColorForMethod,
                            fontFamily: 'Amiri',
                          ),
                        ),
                      ),
                    ),
                    if (verse.sajda?.obligatory == true)
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Container(
                          margin: const EdgeInsets.only(right: 4.0, left: 4.0),
                          child: Icon(
                            Icons.star,
                            color: Colors.green.shade700,
                            size: 18,
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

  String _toArabicNumbers(String number) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    for (int i = 0; i < english.length; i++) {
      number = number.replaceAll(english[i], arabic[i]);
    }
    return number;
  }
}
