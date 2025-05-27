import 'package:flutter/material.dart';
import 'package:serat/domain/models/hadith_model.dart';
import 'package:serat/shared/constants/app_colors.dart';
import 'package:serat/Presentation/screens/Ahadith_screen/base_ahadith_screen.dart';

class HadithCard extends StatelessWidget {
  final HadithModel hadith;
  final bool isBookmarked;
  final Function(HadithModel) onBookmarkToggle;
  final bool isDarkMode;

  const HadithCard({
    super.key,
    required this.hadith,
    required this.isBookmarked,
    required this.onBookmarkToggle,
    required this.isDarkMode,
  });

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
                          child: Text(
                            hadith.hadithNumber,
                            style: TextStyle(
                              fontFamily: 'DIN',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode
                                  ? Colors.white
                                  : AppColors.primaryColor,
                            ),
                          ),
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
}
