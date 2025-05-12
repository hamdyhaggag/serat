import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import 'package:serat/imports.dart';
import 'package:serat/data/services/hadith_service.dart';
import 'package:serat/data/services/bookmark_service.dart';
import 'package:serat/domain/models/hadith_model.dart';
import 'base_ahadith_screen.dart';

class AhadithListScreen extends StatefulWidget {
  const AhadithListScreen({super.key});

  @override
  State<AhadithListScreen> createState() => _AhadithListScreenState();
}

class _AhadithListScreenState extends State<AhadithListScreen>
    with SingleTickerProviderStateMixin {
  final HadithService _hadithService = HadithService();
  final BookmarkService _bookmarkService = BookmarkService();
  List<HadithModel> _hadiths = [];
  List<HadithModel> _filteredHadiths = [];
  bool _isLoading = true;
  String? _error;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'الكل';
  final Map<String, bool> _bookmarkStatus = {};
  bool _isLoadingBookmarks = false;

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
    super.dispose();
  }

  Future<void> _loadData() async {
    await _loadHadiths();
  }

  Future<void> _loadHadiths() async {
    try {
      final hadiths = await _hadithService.getNawawiHadiths();
      setState(() {
        _hadiths = hadiths;
        _filteredHadiths = hadiths;
        _isLoading = false;
      });
      _loadBookmarkStatus();
      _animationController.forward();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadBookmarkStatus() async {
    if (_isLoadingBookmarks) return;
    _isLoadingBookmarks = true;

    try {
      final bookmarkedHadiths = await _bookmarkService.getBookmarkedHadiths();
      setState(() {
        for (var hadith in _hadiths) {
          _bookmarkStatus[hadith.id.toString()] = bookmarkedHadiths.any(
            (h) => h.id == hadith.id,
          );
        }
      });
    } finally {
      _isLoadingBookmarks = false;
    }
  }

  Future<void> _toggleBookmark(HadithModel hadith) async {
    final isBookmarked = _bookmarkStatus[hadith.id.toString()] ?? false;
    setState(() {
      _bookmarkStatus[hadith.id.toString()] = !isBookmarked;
    });

    // Update filtered list if we're in bookmarks view
    if (_selectedFilter == 'المحفوظات') {
      setState(() {
        _filteredHadiths =
            _hadiths
                .where((h) => _bookmarkStatus[h.id.toString()] ?? false)
                .toList();
      });
    }
  }

  void _filterHadiths(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredHadiths = _hadiths;
      } else {
        _filteredHadiths =
            _hadiths
                .where(
                  (hadith) =>
                      hadith.hadithText.toLowerCase().contains(
                        query.toLowerCase(),
                      ) ||
                      hadith.hadithNumber.toLowerCase().contains(
                        query.toLowerCase(),
                      ),
                )
                .toList();
      }
    });
  }

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      if (filter == 'المحفوظات') {
        _filteredHadiths =
            _hadiths
                .where((h) => _bookmarkStatus[h.id.toString()] ?? false)
                .toList();
      } else {
        _filteredHadiths = _hadiths;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xff1F1F1F) : Colors.grey[50],
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              isDarkMode ? Brightness.light : Brightness.dark,
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'الأربعين النووية',
          style: TextStyle(
            fontFamily: 'DIN',
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : AppColors.primaryColor,
          ),
        ),
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:
                isDarkMode ? Colors.white.withValues(alpha: 26) : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: isDarkMode ? Colors.white : AppColors.primaryColor,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(isDarkMode),
          _buildFilterChips(isDarkMode),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: _filterHadiths,
        decoration: InputDecoration(
          hintText: 'ابحث عن حديث...',
          hintStyle: TextStyle(
            color: isDarkMode ? Colors.white54 : Colors.black54,
            fontFamily: 'DIN',
          ),
          prefixIcon: Icon(
            Icons.search,
            color: isDarkMode ? Colors.white54 : Colors.black54,
          ),
          filled: true,
          fillColor:
              isDarkMode ? Colors.white.withValues(alpha: 26) : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontFamily: 'DIN',
        ),
      ),
    );
  }

  Widget _buildFilterChips(bool isDarkMode) {
    final filters = ['الكل', 'المحفوظات'];
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = filter == _selectedFilter;
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(
                filter,
                style: TextStyle(
                  color:
                      isSelected
                          ? Colors.white
                          : isDarkMode
                          ? Colors.white70
                          : Colors.black87,
                  fontFamily: 'DIN',
                ),
              ),
              backgroundColor:
                  isDarkMode
                      ? Colors.white.withValues(alpha: 26)
                      : Colors.white,
              selectedColor: AppColors.primaryColor,
              onSelected: (_) => _applyFilter(filter),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildShimmerLoading();
    }

    if (_error != null) {
      return Center(
        child: Text(
          'حدث خطأ: $_error',
          style: const TextStyle(color: Colors.red, fontFamily: 'DIN'),
        ),
      );
    }

    if (_filteredHadiths.isEmpty) {
      return Center(
        child: Text(
          'لا توجد نتائج',
          style: TextStyle(
            color:
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.white70
                    : Colors.black54,
            fontFamily: 'DIN',
            fontSize: 18,
          ),
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredHadiths.length,
        itemBuilder: (context, index) {
          final hadith = _filteredHadiths[index];
          return _buildHadithCard(hadith, index);
        },
      ),
    );
  }

  Widget _buildHadithCard(HadithModel hadith, int index) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isBookmarked = _bookmarkStatus[hadith.id.toString()] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: isDarkMode ? Colors.white.withValues(alpha: 26) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => BaseAhadithScreen(
                    title: hadith.hadithNumber,
                    hadith: hadith,
                  ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isDarkMode
                              ? AppColors.primaryColor.withValues(alpha: 51)
                              : AppColors.primaryColor.withValues(alpha: 26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      hadith.hadithNumber,
                      style: TextStyle(
                        fontFamily: 'DIN',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color:
                            isDarkMode ? Colors.white : AppColors.primaryColor,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color:
                          isBookmarked
                              ? AppColors.primaryColor
                              : isDarkMode
                              ? Colors.white54
                              : Colors.black54,
                    ),
                    onPressed: () => _toggleBookmark(hadith),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                hadith.hadithText,
                style: TextStyle(
                  fontFamily: 'DIN',
                  fontSize: 16,
                  height: 1.5,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              height: 120,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
