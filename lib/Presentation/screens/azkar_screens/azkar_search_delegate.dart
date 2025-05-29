import 'package:flutter/material.dart';
import 'package:serat/features/azkar/domain/azkar_model.dart';
import 'package:serat/Presentation/Config/constants/colors.dart';

class AzkarSearchDelegate extends SearchDelegate<Azkar?> {
  final List<Azkar> azkarList;
  final Map<String, List<Azkar>> _searchCache = {};
  static const int _maxCacheSize = 100;

  AzkarSearchDelegate(this.azkarList);

  @override
  ThemeData appBarTheme(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Theme.of(context).copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: isDarkMode ? const Color(0xff1F1F1F) : Colors.white,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(
          color: isDarkMode ? Colors.white70 : Colors.black54,
          fontFamily: 'DIN',
        ),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
          },
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    if (query.isEmpty) {
      return _buildEmptyState(context, 'اكتب للبحث عن ذكر');
    }

    final results = _performSearch();

    if (results.isEmpty) {
      return _buildEmptyState(context, 'لا توجد نتائج للبحث عن "$query"');
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final azkar = results[index];
        return _buildAzkarCard(context, azkar);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: (isDarkMode ? Colors.white : Colors.black).withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontFamily: 'DIN',
              fontSize: 16,
              color:
                  (isDarkMode ? Colors.white : Colors.black).withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAzkarCard(BuildContext context, Azkar azkar) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDarkMode ? const Color(0xff2D2D2D) : Colors.white,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        title: Text(
          azkar.text,
          style: TextStyle(
            fontFamily: 'DIN',
            fontSize: 16,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'عدد المرات: ${azkar.count}',
                  style: TextStyle(
                    fontFamily: 'DIN',
                    fontSize: 14,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        onTap: () {
          close(context, azkar);
        },
      ),
    );
  }

  List<Azkar> _performSearch() {
    // Check cache first
    if (_searchCache.containsKey(query)) {
      return _searchCache[query]!;
    }

    final results = <Azkar>[];
    final queryLower = query.toLowerCase();

    for (var azkar in azkarList) {
      if (_matchesSearch(azkar, queryLower)) {
        results.add(azkar);
      }
    }

    // Cache the results
    _searchCache[query] = results;

    // Limit cache size
    if (_searchCache.length > _maxCacheSize) {
      _searchCache.remove(_searchCache.keys.first);
    }

    return results;
  }

  bool _matchesSearch(Azkar azkar, String queryLower) {
    final textLower = azkar.text.toLowerCase();
    final countStr = azkar.count.toString();
    final categoryLower = azkar.category?.toLowerCase() ?? '';

    // Direct text match
    if (textLower.contains(queryLower)) {
      return true;
    }

    // Count match
    if (countStr.contains(queryLower)) {
      return true;
    }

    // Category match
    if (categoryLower.contains(queryLower)) {
      return true;
    }

    // Word boundary matching for better results
    final words = queryLower.split(' ');
    return words.every(
        (word) => textLower.contains(word) || categoryLower.contains(word));
  }
}
