import 'package:flutter/material.dart';
import 'package:serat/domain/models/hadith_model.dart';
import 'package:serat/shared/constants/app_colors.dart';
import 'package:serat/Presentation/screens/Ahadith_screen/base_ahadith_screen.dart';

class HadithCard extends StatelessWidget {
  final HadithModel hadith;
  final bool isBookmarked;
  final Function(HadithModel) onBookmarkToggle;
  final bool isDarkMode;
  final String searchQuery;

  const HadithCard({
    super.key,
    required this.hadith,
    required this.isBookmarked,
    required this.onBookmarkToggle,
    required this.isDarkMode,
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
          height: 1.5,
          color: isDarkMode ? Colors.white70 : Colors.black87,
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      );
    }

    final parts = text.split(RegExp(r'<highlight>(.*?)</highlight>'));
    return RichText(
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
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
                height: 1.5,
                color: isDarkMode ? Colors.white70 : Colors.black87,
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
              height: 1.5,
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BaseAhadithScreen(
                title: hadith.hadithNumber,
                hadith: hadith,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? AppColors.primaryColor.withOpacity(0.2)
                                : AppColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _buildHighlightedText(
                              _highlightText(hadith.hadithNumber)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: isBookmarked
                          ? AppColors.primaryColor
                          : isDarkMode
                              ? Colors.white54
                              : Colors.black54,
                    ),
                    onPressed: () => onBookmarkToggle(hadith),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildHighlightedText(_highlightText(hadith.hadithText)),
            ],
          ),
        ),
      ),
    );
  }
}
