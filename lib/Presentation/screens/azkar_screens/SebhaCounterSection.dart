import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:serat/Presentation/theme/app_theme.dart';

class SebhaCounterSection extends StatelessWidget {
  final int total;
  final int currentCount;
  final int cycleCount;
  final int beadCount;
  final String title;
  final String subtitle;

  const SebhaCounterSection({
    super.key,
    required this.total,
    required this.currentCount,
    required this.cycleCount,
    required this.beadCount,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Title Section
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isDarkMode
                        ? AppTheme.primaryLight
                        : AppTheme.primaryLight,
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.1),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      )
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.05)
                        : Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'DIN',
                      fontSize: 16.sp,
                      color: textColor.withOpacity(0.8),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Stats Row
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.white.withOpacity(0.05)
                  : Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color:
                    isDarkMode ? Colors.white.withOpacity(0.1) : Colors.white,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCounterBox('عدد الدورات', cycleCount, isDarkMode),
                Container(
                    width: 1, height: 40, color: Colors.grey.withOpacity(0.2)),
                _buildCounterBox('الإجمالي', total, isDarkMode,
                    isPrimary: true),
                Container(
                    width: 1, height: 40, color: Colors.grey.withOpacity(0.2)),
                _buildCounterBox('عدد التكرارات', beadCount, isDarkMode),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterBox(String label, int count, bool isDarkMode,
      {bool isPrimary = false}) {
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            color: isPrimary
                ? (isDarkMode ? AppTheme.secondaryLight : AppTheme.primaryLight)
                : textColor,
            fontSize: isPrimary ? 24.sp : 20.sp,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo', // Ensure consistent font
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            color: textColor.withOpacity(0.6),
            fontSize: 12.sp,
            fontFamily: 'DIN',
          ),
        ),
      ],
    );
  }
}
