import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:serat/domain/models/hadith_model.dart';
import 'package:serat/Presentation/widgets/hadith_card.dart';
import 'package:serat/shared/constants/app_colors.dart';

class HadithChapterExpansion extends StatelessWidget {
  final String chapterName;
  final List<HadithModel> hadiths;
  final bool isDarkMode;
  final Function(HadithModel) onBookmarkToggle;
  final Function(HadithModel) isBookmarked;
  final String searchQuery;
  final String? bookId; // Add bookId to determine if should be expanded

  const HadithChapterExpansion({
    super.key,
    required this.chapterName,
    required this.hadiths,
    required this.isDarkMode,
    required this.onBookmarkToggle,
    required this.isBookmarked,
    this.searchQuery = '',
    this.bookId,
  });

  String _highlightText(String text) {
    if (searchQuery.isEmpty) return text;

    final words = searchQuery.split(' ').where((word) => word.isNotEmpty);
    String highlightedText = text;

    for (final word in words) {
      final regex = RegExp(word, caseSensitive: false);
      highlightedText = highlightedText.replaceAllMapped(
        regex,
        (match) => '<highlight>${match.group(0)}</highlight>',
      );
    }

    return highlightedText;
  }

  Widget _buildHighlightedText(String text) {
    if (searchQuery.isEmpty) {
      return Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.menu_book_rounded,
              color: AppColors.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${hadiths.length} حديث',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ],
      );
    }

    final highlightedText = _highlightText(text);
    final parts = highlightedText.split(RegExp(r'<highlight>|</highlight>'));
    final List<TextSpan> spans = [];

    for (int i = 0; i < parts.length; i++) {
      if (i % 2 == 1) {
        spans.add(TextSpan(
          text: parts[i],
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
            backgroundColor: AppColors.primaryColor.withOpacity(0.3),
          ),
        ));
      } else {
        spans.add(TextSpan(
          text: parts[i],
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ));
      }
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.menu_book_rounded,
            color: AppColors.primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(text: TextSpan(children: spans)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${hadiths.length} حديث',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xff1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          initiallyExpanded:
              bookId == 'nawawi', // Only expanded for الأربعين النووية
          backgroundColor: Colors.transparent,
          collapsedBackgroundColor: Colors.transparent,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.only(bottom: 8),
          iconColor: AppColors.primaryColor,
          collapsedIconColor: isDarkMode ? Colors.white54 : Colors.black45,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: _buildHighlightedText(chapterName),
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppColors.primaryColor.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            ...hadiths.map((hadith) => HadithCard(
                  hadith: hadith,
                  isBookmarked: isBookmarked(hadith),
                  onBookmarkToggle: onBookmarkToggle,
                  isDarkMode: isDarkMode,
                  searchQuery: searchQuery,
                )),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.05, end: 0);
  }
}
