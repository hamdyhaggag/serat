import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:serat/imports.dart' hide AppColors;
import 'package:serat/data/services/hadith_database_service.dart';
import 'package:serat/shared/constants/app_colors.dart';
import 'ahadith_list_screen.dart';

class HadithBooksScreen extends StatefulWidget {
  const HadithBooksScreen({super.key});

  @override
  State<HadithBooksScreen> createState() => _HadithBooksScreenState();
}

class _HadithBooksScreenState extends State<HadithBooksScreen>
    with SingleTickerProviderStateMixin {
  final HadithDatabaseService _hadithDatabaseService = HadithDatabaseService();
  Map<String, String> _hadithBooks = {};
  bool _isLoading = true;
  late AnimationController _animationController;
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;
  List<MapEntry<String, String>> _filteredBooks = [];

  // Book metadata with icons and descriptions
  final Map<String, Map<String, dynamic>> _bookMetadata = {
    'الأربعين النووية': {
      'icon': Icons.auto_stories_rounded,
      'color': const Color(0xff4CAF50),
      'description': 'أربعون حديثاً جامعة لأصول الإسلام',
      'count': '42'
    },
    'صحيح البخاري': {
      'icon': Icons.menu_book_rounded,
      'color': const Color(0xff2196F3),
      'description': 'أصح كتاب بعد كتاب الله',
      'count': '7563'
    },
    'صحيح مسلم': {
      'icon': Icons.book_rounded,
      'color': const Color(0xff9C27B0),
      'description': 'ثاني أصح كتب الحديث',
      'count': '7190'
    },
    'سنن أبي داود': {
      'icon': Icons.library_books_rounded,
      'color': const Color(0xffFF9800),
      'description': 'من أمهات كتب السنة',
      'count': '5274'
    },
    'سنن الترمذي': {
      'icon': Icons.import_contacts_rounded,
      'color': const Color(0xffF44336),
      'description': 'الجامع الصحيح',
      'count': '3956'
    },
    'سنن النسائي': {
      'icon': Icons.chrome_reader_mode_rounded,
      'color': const Color(0xff00BCD4),
      'description': 'المجتبى من السنن',
      'count': '5758'
    },
    'سنن ابن ماجه': {
      'icon': Icons.collections_bookmark_rounded,
      'color': const Color(0xff673AB7),
      'description': 'أحد كتب السنن الستة',
      'count': '4341'
    },
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _loadBooks();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBooks() async {
    try {
      final books = await _hadithDatabaseService.getBooks();
      print('📚 Loaded ${books.length} books from service');
      if (!mounted) return;

      setState(() {
        _hadithBooks = Map.fromEntries(
            books.map((book) => MapEntry(book['name']!, book['id']!)));
        _filteredBooks = _hadithBooks.entries.toList();
        _isLoading = false;
      });
      print('📚 Books loaded successfully: ${_hadithBooks.keys.join(", ")}');
      _animationController.forward();
    } catch (e) {
      print('❌ Error loading books from service: $e');
      if (!mounted) return;
      setState(() {
        // Fallback books
        _hadithBooks = {
          'الأربعين النووية': 'nawawi',
          'صحيح البخاري': 'bukhari',
          'صحيح مسلم': 'muslim',
          'سنن أبي داود': 'abudawud',
          'سنن الترمذي': 'tirmidhi',
          'سنن النسائي': 'nasai',
          'سنن ابن ماجه': 'ibnmajah',
        };
        _filteredBooks = _hadithBooks.entries.toList();
        _isLoading = false;
      });
      print('📚 Using fallback books list');
      _animationController.forward();
    }
  }

  void _filterBooks(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredBooks = _hadithBooks.entries.toList();
      } else {
        _filteredBooks = _hadithBooks.entries
            .where((entry) => entry.key.contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xff121212) : const Color(0xffF8F9FA),
      body: _isLoading
          ? _buildShimmerLoading(isDarkMode)
          : _buildContent(isDarkMode),
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
                _buildPremiumHero(isDarkMode),
                const SizedBox(height: 32),
                Text(
                  "كتب الأحاديث",
                  style: TextStyle(
                    fontFamily: "Cairo",
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ).animate().fade(delay: 300.ms).slideX(begin: -0.1, end: 0),
                const SizedBox(height: 8),
                Text(
                  "اختر الكتاب الذي تريد تصفحه",
                  style: TextStyle(
                    fontFamily: "Cairo",
                    fontSize: 14,
                    color: isDarkMode ? Colors.white60 : Colors.black54,
                  ),
                ).animate().fade(delay: 400.ms),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        _filteredBooks.isEmpty
            ? SliverFillRemaining(child: _buildEmptyState(isDarkMode))
            : SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final book = _filteredBooks[index];
                      return _buildBookCard(
                          book.key, book.value, isDarkMode, index);
                    },
                    childCount: _filteredBooks.length,
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
      automaticallyImplyLeading: false,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor:
          isDarkMode ? const Color(0xff121212) : AppColors.primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: const EdgeInsets.only(bottom: 16),
        title: Text(
          'مكتبة الأحاديث',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w900,
            fontSize: 22,
            color: Colors.white,
            shadows: [
              Shadow(
                  blurRadius: 10,
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(0, 2)),
            ],
          ),
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
                    isDarkMode
                        ? const Color(0xff121212)
                        : const Color(0xffF8F9FA),
                  ],
                  stops: const [0.0, 0.7, 1.0],
                ),
              ),
            ),
            Positioned(
              right: -30,
              top: -10,
              child: Opacity(
                opacity: 0.1,
                child: Icon(Icons.library_books_rounded,
                    size: 180, color: Colors.white),
              ),
            ),
            Positioned(
              left: -20,
              bottom: 20,
              child: Opacity(
                opacity: 0.05,
                child: Icon(Icons.auto_awesome, size: 80, color: Colors.white),
              ),
            ),
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
              borderRadius: BorderRadius.circular(12),
            ),
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

  Widget _buildPremiumHero(bool isDarkMode) {
    return Container(
      width: double.infinity,
      height: 160,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDarkMode
                      ? [const Color(0xff2A2A2A), const Color(0xff1E1E1E)]
                      : [Colors.white, const Color(0xffF0F4F8)],
                ),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.primaryColor
                          .withOpacity(isDarkMode ? 0.2 : 0.1),
                      blurRadius: 25,
                      offset: const Offset(0, 15)),
                ],
                border: Border.all(
                    color: Colors.white.withOpacity(isDarkMode ? 0.05 : 0.8),
                    width: 1.5),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.only(bottomRight: Radius.circular(32)),
              child: Opacity(
                opacity: 0.03,
                child: Icon(Icons.format_quote_rounded,
                    size: 120, color: isDarkMode ? Colors.white : Colors.black),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        "السنة النبوية",
                        style: TextStyle(
                            fontFamily: "Cairo",
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColor),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "كنوز من هدي النبي ﷺ",
                        style: TextStyle(
                            fontFamily: "Cairo",
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            height: 1.2,
                            color: isDarkMode
                                ? Colors.white
                                : const Color(0xff1A1C1E)),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "« تركت فيكم ما إن تمسكتم به لن تضلوا بعدي أبداً »",
                        style: TextStyle(
                            fontFamily: "Cairo",
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color:
                                isDarkMode ? Colors.white70 : Colors.black54),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8)),
                    ],
                  ),
                  child: const Icon(Icons.library_books_rounded,
                      color: Colors.white, size: 32),
                ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(
                    begin: -5,
                    end: 5,
                    duration: 2.seconds,
                    curve: Curves.easeInOut),
              ],
            ),
          ),
        ],
      ),
    ).animate().fade().slideY(begin: 0.2, end: 0);
  }

  Widget _buildBookCard(
      String bookName, String bookId, bool isDarkMode, int index) {
    final metadata = _bookMetadata[bookName] ??
        {
          'icon': Icons.book_rounded,
          'color': AppColors.primaryColor,
          'description': 'كتاب من كتب السنة',
          'count': '---'
        };

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xff262626) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AhadithListScreen(
                  bookName: bookName,
                  bookId: bookId,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: (metadata['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    metadata['icon'] as IconData,
                    color: metadata['color'] as Color,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bookName,
                        style: TextStyle(
                          fontFamily: "Cairo",
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        metadata['description'] as String,
                        style: TextStyle(
                          fontFamily: "Cairo",
                          fontSize: 13,
                          color: isDarkMode ? Colors.white60 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (metadata['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${metadata['count']} حديث',
                          style: TextStyle(
                            fontFamily: "Cairo",
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: metadata['color'] as Color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: isDarkMode ? Colors.white30 : Colors.black26,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fade(delay: (index * 50).ms).slideX(begin: 0.1, end: 0);
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
              offset: const Offset(0, 4)),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filterBooks,
        style: TextStyle(
            fontFamily: "Cairo",
            color: isDarkMode ? Colors.white : Colors.black),
        decoration: InputDecoration(
          hintText: "ابحث عن كتاب...",
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
          Icon(Icons.search_off_rounded,
              size: 60, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            "لا توجد نتائج بحث",
            style: TextStyle(
                fontFamily: "Cairo",
                fontSize: 18,
                color: isDarkMode ? Colors.white54 : Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading(bool isDarkMode) {
    return Shimmer.fromColors(
      baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(expandedHeight: 140, backgroundColor: Colors.white),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                      height: 160,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32))),
                  const SizedBox(height: 32),
                  ...List.generate(
                    5,
                    (index) => Container(
                      height: 100,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
