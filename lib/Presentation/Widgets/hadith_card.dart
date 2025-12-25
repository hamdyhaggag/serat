import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:serat/domain/models/hadith_model.dart';
import 'package:serat/Presentation/screens/Ahadith_screen/base_ahadith_screen.dart';
import 'package:serat/shared/constants/app_colors.dart';

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

  Widget _buildHighlightedText(String text, TextStyle baseStyle) {
    if (searchQuery.isEmpty) {
      return Text(text, style: baseStyle);
    }

    final highlightedText = _highlightText(text);
    final parts = highlightedText.split(RegExp(r'<highlight>|</highlight>'));
    final List<TextSpan> spans = [];

    for (int i = 0; i < parts.length; i++) {
      if (i % 2 == 1) {
        // Highlighted part
        spans.add(TextSpan(
          text: parts[i],
          style: baseStyle.copyWith(
            backgroundColor: AppColors.primaryColor.withOpacity(0.3),
            fontWeight: FontWeight.bold,
          ),
        ));
      } else {
        // Normal part
        spans.add(TextSpan(text: parts[i], style: baseStyle));
      }
    }

    return RichText(text: TextSpan(children: spans));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xff1E1E1E) : const Color(0xffFAFAFA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
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
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with hadith number and bookmark
                Row(
                  children: [
                    // Hadith Number Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryColor,
                            AppColors.primaryColor.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.format_quote_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            hadith.hadithNumber,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Bookmark Button
                    Container(
                      decoration: BoxDecoration(
                        color: isBookmarked
                            ? AppColors.primaryColor.withOpacity(0.1)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          isBookmarked
                              ? Icons.bookmark
                              : Icons.bookmark_border_rounded,
                          color: isBookmarked
                              ? AppColors.primaryColor
                              : (isDarkMode ? Colors.white54 : Colors.black45),
                          size: 22,
                        ),
                        onPressed: () => onBookmarkToggle(hadith),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Hadith Text
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.03)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Decorative top quote
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.format_quote,
                              color: AppColors.primaryColor,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'نص الحديث',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildHighlightedText(
                        hadith.hadithText,
                        TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16,
                          height: 1.8,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),

                // Narrator if available
                if (hadith.narrator.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.amber.withOpacity(0.1)
                          : Colors.amber.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.amber.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_outline_rounded,
                          color: Colors.amber.shade700,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            hadith.narrator,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode
                                  ? Colors.amber.shade200
                                  : Colors.amber.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Explanation preview if available
                if (hadith.explanation.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.blue.withOpacity(0.05)
                          : Colors.blue.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline_rounded,
                          color: Colors.blue.shade400,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            hadith.explanation.length > 100
                                ? '${hadith.explanation.substring(0, 100)}...'
                                : hadith.explanation,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13,
                              color: isDarkMode
                                  ? Colors.blue.shade200
                                  : Colors.blue.shade900,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 8),

                // Read more indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'اقرأ المزيد',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: AppColors.primaryColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }
}
