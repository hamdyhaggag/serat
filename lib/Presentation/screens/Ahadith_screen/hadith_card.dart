import 'package:flutter/material.dart';
import 'package:serat/imports.dart' hide AppColors;
import 'package:serat/shared/constants/app_colors.dart';

class HadithCard extends StatelessWidget {
  final String hadithNumber;
  final String hadithText;
  final String explanation;
  final String heroTag;
  final double fontSize;

  const HadithCard({
    super.key,
    required this.hadithNumber,
    required this.hadithText,
    required this.explanation,
    required this.heroTag,
    this.fontSize = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Hero(
      tag: heroTag,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xff1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color:
                  AppColors.primaryColor.withOpacity(isDarkMode ? 0.15 : 0.08),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
          border: Border.all(
            color: isDarkMode
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.03),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  hadithNumber,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: fontSize + 2,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              hadithText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: fontSize + 1,
                height: 1.8,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : const Color(0xff1A1C2E),
              ),
            ),
            if (explanation.isNotEmpty) ...[
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.03)
                      : const Color(0xffF8FAFF),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.05)
                        : AppColors.primaryColor.withOpacity(0.1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline_rounded,
                            size: 20, color: AppColors.primaryColor),
                        const SizedBox(width: 10),
                        Text(
                          'الشرح والفوائد',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: fontSize,
                            fontWeight: FontWeight.w800,
                            color: isDarkMode
                                ? Colors.white
                                : const Color(0xff2D3142),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      explanation,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: fontSize - 1,
                        height: 1.7,
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
