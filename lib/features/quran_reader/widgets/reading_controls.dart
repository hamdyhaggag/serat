/// Reading Controls Widget - Bottom sheet with reader settings
/// Font size, theme selection, and navigation

import 'package:flutter/material.dart';
import 'package:serat/Presentation/Config/constants/colors.dart';
import '../theme/quran_reader_theme.dart';
import '../data/quran_page_data.dart';

class ReadingControlsSheet extends StatelessWidget {
  final double fontSize;
  final QuranReaderTheme currentTheme;
  final int currentPage;
  final int totalPages;
  final Function(double) onFontSizeChanged;
  final Function(QuranReaderTheme) onThemeChanged;
  final Function(int) onPageJump;
  final VoidCallback? onBookmark;
  final bool isBookmarked;

  const ReadingControlsSheet({
    super.key,
    required this.fontSize,
    required this.currentTheme,
    required this.currentPage,
    required this.totalPages,
    required this.onFontSizeChanged,
    required this.onThemeChanged,
    required this.onPageJump,
    this.onBookmark,
    this.isBookmarked = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? const Color(0xFF2D2D2D) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'إعدادات القراءة',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'DIN',
                    color: textColor,
                  ),
                ),
                // Bookmark button
                if (onBookmark != null)
                  IconButton(
                    onPressed: onBookmark,
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: AppColors.primaryColor,
                      size: 28,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Font Size Section
          _buildSection(
            title: 'حجم الخط',
            icon: Icons.text_fields,
            textColor: textColor,
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'أ',
                      style: TextStyle(
                        fontSize: 16,
                        color: textColor.withValues(alpha: 0.6),
                        fontFamily: 'Amiri',
                      ),
                    ),
                    Expanded(
                      child: Slider(
                        value: fontSize,
                        min: QuranTypography.minFontSize,
                        max: QuranTypography.maxFontSize,
                        divisions: 10,
                        activeColor: AppColors.primaryColor,
                        inactiveColor: AppColors.primaryColor.withValues(alpha: 0.2),
                        onChanged: onFontSizeChanged,
                      ),
                    ),
                    Text(
                      'أ',
                      style: TextStyle(
                        fontSize: 28,
                        color: textColor.withValues(alpha: 0.6),
                        fontFamily: 'Amiri',
                      ),
                    ),
                  ],
                ),
                // Preview text
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.black.withValues(alpha: 0.2)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                    style: QuranTypography.quranTextStyle(
                      fontSize: fontSize,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Theme Selection Section
          _buildSection(
            title: 'نمط القراءة',
            icon: Icons.palette,
            textColor: textColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildThemeOption(
                    context: context,
                    theme: QuranReaderTheme.light,
                    label: 'نهاري',
                    backgroundColor: QuranReaderColors.lightBackground,
                    textColor: QuranReaderColors.lightTextColor,
                    borderColor: QuranReaderColors.lightFrameColor,
                    isSelected: currentTheme == QuranReaderTheme.light,
                  ),
                  _buildThemeOption(
                    context: context,
                    theme: QuranReaderTheme.sepia,
                    label: 'دافئ',
                    backgroundColor: QuranReaderColors.sepiaBackground,
                    textColor: QuranReaderColors.sepiaTextColor,
                    borderColor: QuranReaderColors.sepiaFrameColor,
                    isSelected: currentTheme == QuranReaderTheme.sepia,
                  ),
                  _buildThemeOption(
                    context: context,
                    theme: QuranReaderTheme.dark,
                    label: 'ليلي',
                    backgroundColor: QuranReaderColors.darkBackground,
                    textColor: QuranReaderColors.darkTextColor,
                    borderColor: QuranReaderColors.darkFrameColor,
                    isSelected: currentTheme == QuranReaderTheme.dark,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Page Navigation Section
          _buildSection(
            title: 'الانتقال إلى صفحة',
            icon: Icons.menu_book,
            textColor: textColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'صفحة',
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor.withValues(alpha: 0.7),
                      fontFamily: 'DIN',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        showValueIndicator: ShowValueIndicator.always,
                      ),
                      child: Slider(
                        value: currentPage.toDouble(),
                        min: 1,
                        max: totalPages.toDouble(),
                        divisions: totalPages - 1,
                        activeColor: AppColors.primaryColor,
                        inactiveColor: AppColors.primaryColor.withValues(alpha: 0.2),
                        label: ArabicNumbers.convert(currentPage),
                        onChanged: (value) {
                          onPageJump(value.round());
                        },
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      ArabicNumbers.convert(currentPage),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'DIN',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color textColor,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: AppColors.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'DIN',
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required QuranReaderTheme theme,
    required String label,
    required Color backgroundColor,
    required Color textColor,
    required Color borderColor,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => onThemeChanged(theme),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 90,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? borderColor : Colors.transparent,
            width: 3,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: borderColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Text(
              'ق',
              style: TextStyle(
                fontSize: 24,
                fontFamily: 'AmiriQuran',
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'DIN',
                color: textColor,
              ),
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 4),
                child: Icon(
                  Icons.check_circle,
                  size: 18,
                  color: borderColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Floating controls that appear when tapping the screen
class QuranFloatingControls extends StatelessWidget {
  final VoidCallback onSettingsPressed;
  final VoidCallback onPlayPressed;
  final VoidCallback onBookmarkPressed;
  final VoidCallback onSurahListPressed;
  final bool isPlaying;
  final bool showControls;

  const QuranFloatingControls({
    super.key,
    required this.onSettingsPressed,
    required this.onPlayPressed,
    required this.onBookmarkPressed,
    required this.onSurahListPressed,
    this.isPlaying = false,
    this.showControls = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!showControls) return const SizedBox.shrink();

    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: AnimatedOpacity(
        opacity: showControls ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                icon: Icons.list,
                label: 'السور',
                onPressed: onSurahListPressed,
              ),
              _buildControlButton(
                icon: Icons.bookmark_border,
                label: 'علامة',
                onPressed: onBookmarkPressed,
              ),
              _buildControlButton(
                icon: isPlaying ? Icons.pause : Icons.play_arrow,
                label: isPlaying ? 'إيقاف' : 'تشغيل',
                onPressed: onPlayPressed,
                isHighlighted: true,
              ),
              _buildControlButton(
                icon: Icons.settings,
                label: 'إعدادات',
                onPressed: onSettingsPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isHighlighted = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isHighlighted
                  ? AppColors.primaryColor
                  : Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white70,
              fontFamily: 'DIN',
            ),
          ),
        ],
      ),
    );
  }
}
