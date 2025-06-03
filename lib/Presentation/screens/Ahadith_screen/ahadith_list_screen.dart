import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';
import 'package:serat/imports.dart' hide AppColors;
import 'package:serat/data/services/hadith_service.dart';
import 'package:serat/data/services/bookmark_service.dart';
import 'package:serat/data/services/hadith_database_service.dart';
import 'package:serat/domain/models/hadith_model.dart';
import 'package:serat/domain/models/filter_state.dart';
import 'package:serat/domain/models/search_state.dart';
import 'package:serat/Presentation/widgets/error_widget.dart';
import 'package:serat/Presentation/widgets/hadith_search_bar.dart';
import 'package:serat/Presentation/widgets/hadith_filter_chips.dart';
import 'package:serat/Presentation/widgets/hadith_chapter_expansion.dart';
import 'package:serat/Presentation/widgets/hadith_loading_shimmer.dart';
import 'package:serat/shared/utils/error_mapper.dart';
import 'package:serat/shared/constants/app_colors.dart';

class AhadithListScreen extends StatefulWidget {
  const AhadithListScreen({super.key});

  @override
  State<AhadithListScreen> createState() => _AhadithListScreenState();
}

class _AhadithListScreenState extends State<AhadithListScreen>
    with SingleTickerProviderStateMixin {
  final HadithService _hadithService = HadithService();
  final BookmarkService _bookmarkService = BookmarkService();
  final HadithDatabaseService _hadithDatabaseService = HadithDatabaseService();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final TextEditingController _searchController = TextEditingController();

  List<HadithModel> _hadiths = [];
  Map<String, Set<String>> _bookmarkCache = {};
  Map<String, String> _hadithBooks = {};

  FilterState _filterState = const FilterState();
  SearchState _searchState = const SearchState();

  bool _isLoading = true;
  String? _error;

  // Search optimization variables
  Timer? _debounce;
  String _lastSearchQuery = '';
  Map<String, Map<String, List<HadithModel>>> _searchCache = {};
  final int _debounceMilliseconds = 300;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([_loadHadiths(), _loadAllBookmarks(), _loadBookNames()]);
  }

  Future<void> _loadHadiths() async {
    try {
      final hadiths = await _hadithDatabaseService.getHadiths(
        _filterState.selectedBook,
      );
      if (!mounted) return;

      setState(() {
        _hadiths = hadiths;
        _searchState = _searchState.copyWith(
          filteredHadiths: hadiths,
          groupedHadiths: _groupHadithsByChapter(hadiths),
        );
        _isLoading = false;
        _error = null;
      });
      _animationController.forward();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = ErrorMapper.getHadithErrorMessage(e);
        _isLoading = false;
      });
    }
  }

  Map<String, List<HadithModel>> _groupHadithsByChapter(
    List<HadithModel> hadiths,
  ) {
    final grouped = <String, List<HadithModel>>{};
    for (var hadith in hadiths) {
      if (hadith.chapterName.isEmpty) continue;

      if (!grouped.containsKey(hadith.chapterName)) {
        grouped[hadith.chapterName] = [];
      }
      grouped[hadith.chapterName]!.add(hadith);
    }
    return grouped;
  }

  Future<void> _loadAllBookmarks() async {
    if (_filterState.isLoadingBookmarks) return;
    setState(() {
      _filterState = _filterState.copyWith(isLoadingBookmarks: true);
    });

    try {
      final bookmarkedHadiths = await _bookmarkService.getBookmarkedHadiths();
      for (var hadith in bookmarkedHadiths) {
        final bookId = hadith.bookId;
        if (bookId == null) continue;

        if (!_bookmarkCache.containsKey(bookId)) {
          _bookmarkCache[bookId] = {};
        }
        _bookmarkCache[bookId]!.add(hadith.id.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _filterState = _filterState.copyWith(isLoadingBookmarks: false);
        });
      }
    }
  }

  bool _isBookmarked(HadithModel hadith) {
    if (hadith.bookId == null) return false;
    return _bookmarkCache[hadith.bookId]?.contains(hadith.id.toString()) ??
        false;
  }

  Future<void> _fetchRandomHadith() async {
    setState(() {
      _filterState = _filterState.copyWith(isLoadingRandom: true);
      _error = null;
    });

    try {
      final randomHadith = await _hadithDatabaseService.getRandomHadith(
        _filterState.selectedBook,
      );
      setState(() {
        _searchState = _searchState.copyWith(
          filteredHadiths: [randomHadith],
          groupedHadiths: _groupHadithsByChapter([randomHadith]),
        );
        _filterState = _filterState.copyWith(
          selectedFilter: 'عشوائي',
          isLoadingRandom: false,
        );
      });
    } catch (e) {
      setState(() {
        _error = ErrorMapper.getHadithErrorMessage(e);
        _filterState = _filterState.copyWith(isLoadingRandom: false);
      });
    }
  }

  void _filterHadiths(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(Duration(milliseconds: _debounceMilliseconds), () {
      if (query == _lastSearchQuery) return;
      _lastSearchQuery = query;

      setState(() {
        if (query.isEmpty) {
          _searchState = _searchState.copyWith(
            query: query,
            filteredHadiths: _hadiths,
            groupedHadiths: _groupHadithsByChapter(_hadiths),
          );
        } else {
          // Split query into words for better matching
          final words = query.split(' ').where((word) => word.isNotEmpty);

          _searchState = _searchState.copyWith(
            query: query,
            filteredHadiths: _hadiths.where((hadith) {
              // Normalize text by removing diacritics
              String normalizeText(String text) {
                return text
                    .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'),
                        '') // Remove diacritics
                    .replaceAll('أ', 'ا')
                    .replaceAll('إ', 'ا')
                    .replaceAll('آ', 'ا')
                    .replaceAll('ى', 'ي')
                    .toLowerCase();
              }

              // Search in hadith text (including chain of narrators)
              final textLower = normalizeText(hadith.hadithText);
              final numberLower = normalizeText(hadith.hadithNumber);
              final explanationLower = normalizeText(hadith.explanation);
              final narratorLower = normalizeText(hadith.narrator);
              final normalizedQuery = words.map(normalizeText).toList();

              // Check if all words in the query are found in any of the fields
              return normalizedQuery.every(
                (word) =>
                    textLower.contains(word) ||
                    numberLower.contains(word) ||
                    explanationLower.contains(word) ||
                    narratorLower.contains(word),
              );
            }).toList(),
            groupedHadiths: _groupHadithsByChapter(
              _hadiths.where((hadith) {
                // Normalize text by removing diacritics
                String normalizeText(String text) {
                  return text
                      .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'),
                          '') // Remove diacritics
                      .replaceAll('أ', 'ا')
                      .replaceAll('إ', 'ا')
                      .replaceAll('آ', 'ا')
                      .replaceAll('ى', 'ي')
                      .toLowerCase();
                }

                // Search in hadith text (including chain of narrators)
                final textLower = normalizeText(hadith.hadithText);
                final numberLower = normalizeText(hadith.hadithNumber);
                final explanationLower = normalizeText(hadith.explanation);
                final narratorLower = normalizeText(hadith.narrator);
                final normalizedQuery = words.map(normalizeText).toList();

                // Check if all words in the query are found in any of the fields
                return normalizedQuery.every(
                  (word) =>
                      textLower.contains(word) ||
                      numberLower.contains(word) ||
                      explanationLower.contains(word) ||
                      narratorLower.contains(word),
                );
              }).toList(),
            ),
          );

          // Cache the results
          if (_searchCache.containsKey(_filterState.selectedBook)) {
            _searchCache[_filterState.selectedBook]![query] =
                _searchState.filteredHadiths;
          } else {
            _searchCache[_filterState.selectedBook] = {
              query: _searchState.filteredHadiths,
            };
          }

          // Limit cache size to prevent memory issues
          if (_searchCache[_filterState.selectedBook]!.length > 100) {
            _searchCache[_filterState.selectedBook]!.remove(
              _searchCache[_filterState.selectedBook]!.keys.first,
            );
          }
        }
      });
    });
  }

  void _selectBook(String book) {
    setState(() {
      _filterState = _filterState.copyWith(
        selectedBook: book,
        selectedFilter: 'الكل',
      );
      _searchController.clear();
      _lastSearchQuery = ''; // Reset last search query
    });
    _loadHadiths();
  }

  Future<void> _toggleBookmark(HadithModel hadith) async {
    if (hadith.bookId == null) return;

    try {
      final isBookmarked = _isBookmarked(hadith);

      if (!_bookmarkCache.containsKey(hadith.bookId)) {
        _bookmarkCache[hadith.bookId!] = {};
      }

      if (isBookmarked) {
        _bookmarkCache[hadith.bookId!]!.remove(hadith.id.toString());
      } else {
        _bookmarkCache[hadith.bookId!]!.add(hadith.id.toString());
      }

      if (!mounted) return;
      setState(() {});

      if (_filterState.selectedFilter == 'المحفوظات') {
        if (!mounted) return;
        setState(() {
          _searchState = _searchState.copyWith(
            filteredHadiths: _hadiths.where((h) => _isBookmarked(h)).toList(),
            groupedHadiths: _groupHadithsByChapter(
              _hadiths.where((h) => _isBookmarked(h)).toList(),
            ),
          );
        });
      }

      try {
        if (isBookmarked) {
          await _bookmarkService.removeBookmark(hadith);
        } else {
          await _bookmarkService.addBookmark(hadith);
        }
      } catch (e) {
        if (isBookmarked) {
          _bookmarkCache[hadith.bookId!]!.add(hadith.id.toString());
        } else {
          _bookmarkCache[hadith.bookId!]!.remove(hadith.id.toString());
        }
        if (!mounted) return;
        setState(() {});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ أثناء حفظ الإشارة المرجعية',
              style: TextStyle(fontFamily: 'DIN', color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error toggling bookmark: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'حدث خطأ غير متوقع',
            style: TextStyle(fontFamily: 'DIN', color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _applyFilter(String filter) {
    setState(() {
      _filterState = _filterState.copyWith(selectedFilter: filter);
      if (filter == 'المحفوظات') {
        final bookmarked = _hadiths.where((h) => _isBookmarked(h)).toList();
        _searchState = _searchState.copyWith(
          filteredHadiths: bookmarked,
          groupedHadiths: _groupHadithsByChapter(bookmarked),
        );
      } else if (filter == 'عشوائي') {
        _fetchRandomHadith();
      } else {
        _searchState = _searchState.copyWith(
          filteredHadiths: _hadiths,
          groupedHadiths: _groupHadithsByChapter(_hadiths),
        );
      }
    });
  }

  Future<void> _loadBookNames() async {
    if (_filterState.isLoadingBooks) return;
    setState(() {
      _filterState = _filterState.copyWith(isLoadingBooks: true);
    });

    try {
      final books = await _hadithDatabaseService.getBooks();
      if (!mounted) return;

      setState(() {
        _hadithBooks = Map.fromEntries(
          books.map((book) => MapEntry(book['name']!, book['id']!)),
        );
        if (_hadithBooks.isNotEmpty) {
          _filterState = _filterState.copyWith(
            selectedBook: _hadithBooks.keys.first,
            isLoadingBooks: false,
          );
        }
      });
    } catch (e) {
      print('Error loading book names: $e');
      _hadithBooks = {
        'الأربعين النووية': 'nawawi',
        'صحيح البخاري': 'bukhari',
        'صحيح مسلم': 'muslim',
        'سنن أبي داود': 'abudawud',
        'سنن الترمذي': 'tirmidhi',
        'سنن النسائي': 'nasai',
        'سنن ابن ماجه': 'ibnmajah',
      };
    } finally {
      if (mounted) {
        setState(() {
          _filterState = _filterState.copyWith(isLoadingBooks: false);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? AppColors.darkBackgroundColor
          : AppColors.backgroundColor,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              isDarkMode ? Brightness.light : Brightness.dark,
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          _filterState.selectedBook,
          style: TextStyle(
            fontFamily: 'DIN',
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : AppColors.primaryColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            HadithSearchBar(
              controller: _searchController,
              onChanged: _filterHadiths,
              isDarkMode: isDarkMode,
              resultCount: _searchState.filteredHadiths.length,
              isSearching: _isLoading,
            ),
            HadithFilterChips(
              books: _hadithBooks,
              selectedBook: _filterState.selectedBook,
              selectedFilter: _filterState.selectedFilter,
              isLoadingRandom: _filterState.isLoadingRandom,
              isDarkMode: isDarkMode,
              onBookSelected: _selectBook,
              onFilterSelected: _applyFilter,
            ),
            Expanded(
              child: _isLoading
                  ? const HadithLoadingShimmer()
                  : _error != null
                      ? AppErrorWidget(
                          message: _error!,
                          icon: Icons.error_outline_rounded,
                          isDarkMode: isDarkMode,
                          onRetry: () {
                            if (_filterState.selectedFilter == 'عشوائي') {
                              _fetchRandomHadith();
                            } else {
                              _loadData();
                            }
                          },
                        )
                      : _searchState.filteredHadiths.isEmpty
                          ? Center(
                              child: Text(
                                'لا توجد نتائج',
                                style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.white70
                                      : Colors.black54,
                                  fontFamily: 'DIN',
                                  fontSize: 18,
                                ),
                              ),
                            )
                          : FadeTransition(
                              opacity: _fadeAnimation,
                              child: ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _searchState.groupedHadiths.length,
                                itemBuilder: (context, index) {
                                  try {
                                    final chapterName = _searchState
                                        .groupedHadiths.keys
                                        .elementAt(index);
                                    final hadiths = _searchState
                                        .groupedHadiths[chapterName]!;
                                    return HadithChapterExpansion(
                                      chapterName: chapterName,
                                      hadiths: hadiths,
                                      isDarkMode: isDarkMode,
                                      onBookmarkToggle: _toggleBookmark,
                                      isBookmarked: _isBookmarked,
                                      searchQuery: _searchState.query,
                                    );
                                  } catch (e) {
                                    print('Error building chapter: $e');
                                    return const SizedBox.shrink();
                                  }
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
