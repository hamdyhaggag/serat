import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? AppColors.primaryColor.withOpacity(0.2)
                    : AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                hadithNumber,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'DIN',
                  fontSize: fontSize + 4,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : AppColors.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              hadithText,
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontFamily: 'DIN',
                fontSize: fontSize + 2,
                height: 1.6,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            if (explanation.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.05)
                      : Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.1)
                        : Colors.grey[300]!,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'الشرح',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'DIN',
                        fontSize: fontSize + 2,
                        fontWeight: FontWeight.bold,
                        color:
                            isDarkMode ? Colors.white : AppColors.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      explanation,
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontFamily: 'DIN',
                        fontSize: fontSize,
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
      ),
    );
  }
}
