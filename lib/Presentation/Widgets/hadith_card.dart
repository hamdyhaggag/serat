import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:serat/domain/models/hadith_model.dart';
import 'package:serat/shared/constants/app_colors.dart';
import 'package:share_plus/share_plus.dart';

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
    required this.searchQuery,
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
        spans.add(TextSpan(
          text: parts[i],
          style: baseStyle.copyWith(
            backgroundColor: AppColors.primaryColor.withOpacity(0.3),
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ));
      } else {
        spans.add(TextSpan(
          text: parts[i],
          style: baseStyle,
        ));
      }
    }

    return RichText(
      textAlign: TextAlign.justify,
      text: TextSpan(children: spans),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  hadith.hadithNumber,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => onBookmarkToggle(hadith),
                    icon: Icon(
                      isBookmarked
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_outline_rounded,
                      color: isBookmarked
                          ? AppColors.primaryColor
                          : (isDarkMode ? Colors.white60 : Colors.black45),
                    ),
                    splashRadius: 20,
                  ),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(
                          text: '${hadith.hadithText}\n\n${hadith.narrator}'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'تم نسخ الحديث',
                            style: TextStyle(fontFamily: 'Cairo'),
                          ),
                          backgroundColor: AppColors.primaryColor,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.copy_rounded,
                      color: isDarkMode ? Colors.white60 : Colors.black45,
                      size: 20,
                    ),
                    splashRadius: 20,
                  ),
                  IconButton(
                    onPressed: () {
                      Share.share(
                          '${hadith.hadithText}\n\n${hadith.narrator}\n\nتم المشاركة من تطبيق صراط');
                    },
                    icon: Icon(
                      Icons.share_rounded,
                      color: isDarkMode ? Colors.white60 : Colors.black45,
                      size: 20,
                    ),
                    splashRadius: 20,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildHighlightedText(
            hadith.hadithText,
            TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              height: 1.8,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : const Color(0xff2D3142),
            ),
          ),
          if (hadith.narrator.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              hadith.narrator,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (hadith.explanation.isNotEmpty && hadith.explanation != ' ') ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    isDarkMode ? Colors.black.withOpacity(0.2) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryColor.withOpacity(0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 16,
                        color: AppColors.primaryColor.withOpacity(0.8),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'الشرح',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hadith.explanation,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      height: 1.6,
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
