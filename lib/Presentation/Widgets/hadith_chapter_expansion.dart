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

  const HadithChapterExpansion({
    super.key,
    required this.chapterName,
    required this.hadiths,
    required this.isDarkMode,
    required this.onBookmarkToggle,
    required this.isBookmarked,
  });

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
          title: Text(
            chapterName,
            style: TextStyle(
              fontFamily: 'DIN',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          children: [
            const Divider(height: 1),
            ...hadiths.map((hadith) => HadithCard(
                  hadith: hadith,
                  isBookmarked: isBookmarked(hadith),
                  onBookmarkToggle: onBookmarkToggle,
                  isDarkMode: isDarkMode,
                )),
          ],
        ),
      ),
    );
  }
}
