import 'package:flutter/material.dart';
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

  const HadithChapterExpansion({
    super.key,
    required this.chapterName,
    required this.hadiths,
    required this.isDarkMode,
    required this.onBookmarkToggle,
    required this.isBookmarked,
    this.searchQuery = '',
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
      return Text(
        text,
        style: TextStyle(
          fontFamily: 'DIN',
          fontSize: 16,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      );
    }

    final parts = text.split(RegExp(r'<highlight>(.*?)</highlight>'));
    return RichText(
      text: TextSpan(
        children: parts.map((part) {
          if (part.startsWith('<highlight>') && part.endsWith('</highlight>')) {
            final highlightedText = part
                .replaceAll('<highlight>', '')
                .replaceAll('</highlight>', '');
            return TextSpan(
              text: highlightedText,
              style: TextStyle(
                fontFamily: 'DIN',
                fontSize: 16,
                color: isDarkMode ? Colors.white : Colors.black,
                backgroundColor: isDarkMode
                    ? Colors.yellow.withOpacity(0.3)
                    : Colors.yellow.withOpacity(0.2),
                fontWeight: FontWeight.bold,
              ),
            );
          }
          return TextSpan(
            text: part,
            style: TextStyle(
              fontFamily: 'DIN',
              fontSize: 16,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          initiallyExpanded: false,
          backgroundColor: Colors.transparent,
          collapsedBackgroundColor: Colors.transparent,
          iconColor: isDarkMode ? Colors.white70 : AppColors.primaryColor,
          collapsedIconColor:
              isDarkMode ? Colors.white70 : AppColors.primaryColor,
          textColor: isDarkMode ? Colors.white : AppColors.primaryColor,
          collapsedTextColor:
              isDarkMode ? Colors.white : AppColors.primaryColor,
          title: _buildHighlightedText(_highlightText(chapterName)),
          children: [
            const Divider(height: 1),
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
    );
  }
}
