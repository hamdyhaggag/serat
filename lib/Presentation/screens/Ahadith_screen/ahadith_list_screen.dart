import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import 'package:serat/imports.dart' hide AppColors;
import 'package:serat/data/services/hadith_service.dart';
import 'package:serat/data/services/bookmark_service.dart';
import 'package:serat/data/services/hadith_database_service.dart';
import 'package:serat/domain/models/hadith_model.dart';
import 'package:serat/domain/models/filter_state.dart';
import 'package:serat/domain/models/search_state.dart';
import 'package:serat/Presentation/widgets/hadith_chapter_expansion.dart';
import 'package:serat/Presentation/widgets/hadith_loading_shimmer.dart';
import 'package:serat/shared/constants/app_colors.dart';

// Top-level function required by compute() — runs in a separate isolate.
// Receives a map {hadiths, query} and returns filtered HadithModel list.
List<HadithModel> _filterHadithsIsolate(Map<String, dynamic> args) {
  final hadiths = args['hadiths'] as List<HadithModel>;
  final query = args['query'] as String;
  return hadiths.where((h) {
    return h.hadithText.contains(query) || h.explanation.contains(query);
  }).toList();
}

class AhadithListScreen extends StatefulWidget {
  final String? bookName;
  final String? bookId;

  const AhadithListScreen({
    super.key,
    this.bookName,
    this.bookId,
  });

  @override
  State<AhadithListScreen> createState() => _AhadithListScreenState();
}

class _AhadithListScreenState extends State<AhadithListScreen>
    with SingleTickerProviderStateMixin {
  final HadithService _hadithService = HadithService();
  final BookmarkService _bookmarkService = BookmarkService();
  final HadithDatabaseService _hadithDatabaseService = HadithDatabaseService();

  late AnimationController _animationController;
  final TextEditingController _searchController = TextEditingController();

  List<HadithModel> _hadiths = [];
  Map<String, Set<String>> _bookmarkCache = {};
  Map<String, String> _hadithBooks = {};

  FilterState _filterState = const FilterState();
  SearchState _searchState = const SearchState();

  bool _isLoading = true;
  bool _showSearch = false;

  // Search optimization
  Timer? _debounce;
  String _lastSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    // Set initial book from widget parameters
    if (widget.bookId != null) {
      _filterState = _filterState.copyWith(selectedBook: widget.bookId!);
    }
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
      // Use widget.bookId if provided, otherwise use filterState
      final bookId = widget.bookId ?? _filterState.selectedBook;
      print('📚 Loading hadiths for bookId: $bookId');
      print('📚 widget.bookId: ${widget.bookId}');
      print('📚 widget.bookName: ${widget.bookName}');

      final hadiths = await _hadithDatabaseService.getHadiths(bookId);
      print('📚 Loaded ${hadiths.length} hadiths');

      if (!mounted) return;

      setState(() {
        _hadiths = hadiths;
        _searchState = _searchState.copyWith(
          filteredHadiths: hadiths,
          groupedHadiths: _groupHadithsByChapter(hadiths),
        );
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      print('❌ Error loading hadiths: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Map<String, List<HadithModel>> _groupHadithsByChapter(
      List<HadithModel> hadiths) {
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
    } catch (e) {
      print('Error loading bookmarks: $e');
    }
  }

  bool _isBookmarked(HadithModel hadith) {
    if (hadith.bookId == null) return false;
    return _bookmarkCache[hadith.bookId]?.contains(hadith.id.toString()) ??
        false;
  }

  Future<void> _filterHadiths(String query) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (query == _lastSearchQuery) return;
      _lastSearchQuery = query;

      if (query.isEmpty) {
        if (!mounted) return;
        setState(() {
          _searchState = _searchState.copyWith(
            query: query,
            filteredHadiths: _hadiths,
            groupedHadiths: _groupHadithsByChapter(_hadiths),
          );
        });
        return;
      }

      // Run filtering in a separate isolate to avoid UI jank.
      final filtered = await compute(
        _filterHadithsIsolate,
        {'hadiths': _hadiths, 'query': query},
      );

      if (!mounted) return;
      setState(() {
        _searchState = _searchState.copyWith(
          query: query,
          filteredHadiths: filtered,
          groupedHadiths: _groupHadithsByChapter(filtered),
        );
      });
    });
  }

  Future<void> _toggleBookmark(HadithModel hadith) async {
    if (hadith.bookId == null) return;
    final isBookmarked = _isBookmarked(hadith);

    setState(() {
      if (!_bookmarkCache.containsKey(hadith.bookId))
        _bookmarkCache[hadith.bookId!] = {};
      if (isBookmarked)
        _bookmarkCache[hadith.bookId!]!.remove(hadith.id.toString());
      else
        _bookmarkCache[hadith.bookId!]!.add(hadith.id.toString());
    });

    try {
      if (isBookmarked)
        await _bookmarkService.removeBookmark(hadith);
      else
        await _bookmarkService.addBookmark(hadith);
    } catch (e) {
      setState(() {
        if (isBookmarked)
          _bookmarkCache[hadith.bookId!]!.add(hadith.id.toString());
        else
          _bookmarkCache[hadith.bookId!]!.remove(hadith.id.toString());
      });
    }
  }

  Future<void> _loadBookNames() async {
    try {
      final books = await _hadithDatabaseService.getBooks();
      if (!mounted) return;
      setState(() {
        _hadithBooks = Map.fromEntries(
            books.map((book) => MapEntry(book['name']!, book['id']!)));
        if (_hadithBooks.isNotEmpty && _filterState.selectedBook.isEmpty) {
          _filterState =
              _filterState.copyWith(selectedBook: _hadithBooks.keys.first);
        }
      });
    } catch (e) {
      _hadithBooks = {
        'الأربعين النووية': 'nawawi',
        'صحيح البخاري': 'bukhari',
        'صحيح مسلم': 'muslim'
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xff121212) : const Color(0xffF8F9FA),
      body:
          _isLoading ? const HadithLoadingShimmer() : _buildContent(isDarkMode),
    );
  }

  Widget _buildContent(bool isDarkMode) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildSliverAppBar(isDarkMode),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_showSearch)
                  _buildSearchBar(isDarkMode)
                      .animate()
                      .fade()
                      .slideY(begin: -0.1, end: 0),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        _searchState.filteredHadiths.isEmpty
            ? SliverFillRemaining(child: _buildEmptyState(isDarkMode))
            : SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final chapterName =
                          _searchState.groupedHadiths.keys.elementAt(index);
                      final hadiths = _searchState.groupedHadiths[chapterName]!;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: HadithChapterExpansion(
                          chapterName: chapterName,
                          hadiths: hadiths,
                          isDarkMode: isDarkMode,
                          onBookmarkToggle: _toggleBookmark,
                          isBookmarked: _isBookmarked,
                          searchQuery: _searchState.query,
                          bookId: widget.bookId,
                        ),
                      )
                          .animate()
                          .fade(delay: (index * 50).ms)
                          .slideY(begin: 0.1, end: 0);
                    },
                    childCount: _searchState.groupedHadiths.length,
                  ),
                ),
              ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildSliverAppBar(bool isDarkMode) {
    return SliverAppBar(
      expandedHeight: 140,
      automaticallyImplyLeading: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor:
          isDarkMode ? const Color(0xff121212) : AppColors.primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: const EdgeInsets.only(bottom: 16),
        title: Text(
          widget.bookName ?? 'الأحاديث النبوية',
          style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w900,
              fontSize: 20,
              color: Colors.white,
              shadows: [
                Shadow(
                    blurRadius: 10,
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(0, 2))
              ]),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                  AppColors.primaryColor,
                  AppColors.primaryColor.withOpacity(0.9),
                  isDarkMode ? const Color(0xff121212) : const Color(0xffF8F9FA)
                ],
                        stops: const [
                  0.0,
                  0.7,
                  1.0
                ]))),
            Positioned(
                right: -30,
                top: -10,
                child: Opacity(
                    opacity: 0.1,
                    child: Icon(Icons.auto_stories,
                        size: 180, color: Colors.white))),
            Positioned(
                left: -20,
                bottom: 20,
                child: Opacity(
                    opacity: 0.05,
                    child: Icon(Icons.stars_rounded,
                        size: 80, color: Colors.white))),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12)),
            child: IconButton(
              icon: Icon(_showSearch ? Icons.close : Icons.search,
                  color: Colors.white, size: 20),
              onPressed: () => setState(() => _showSearch = !_showSearch),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
          color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ]),
      child: TextField(
        controller: _searchController,
        onChanged: _filterHadiths,
        style: TextStyle(
            fontFamily: "Cairo",
            color: isDarkMode ? Colors.white : Colors.black),
        decoration: InputDecoration(
          hintText: "ابحث في الكتاب المختار...",
          hintStyle: TextStyle(
              fontFamily: "Cairo",
              color: isDarkMode ? Colors.white54 : Colors.black45),
          prefixIcon: Icon(Icons.search_rounded, color: AppColors.primaryColor),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_stories_outlined,
              size: 60, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text("لا توجد أحاديث في هذا القسم",
              style: TextStyle(
                  fontFamily: "Cairo",
                  fontSize: 18,
                  color: isDarkMode ? Colors.white54 : Colors.black54)),
        ],
      ),
    );
  }
}
