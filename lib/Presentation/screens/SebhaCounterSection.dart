import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 23.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 30.h,
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(color: textColor, fontSize: 18.sp),
                      children: [
                        TextSpan(
                          text: subtitle,
                          style: TextStyle(fontFamily: 'DIN', fontSize: 13.sp),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 25.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCounterBox('عدد الدورات', cycleCount, textColor),
              _buildCounterBox('الإجمالي', total, textColor),
              _buildCounterBox('عدد التكرارات', beadCount, textColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCounterBox(String label, int count, Color textColor) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            border: Border.all(color: textColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$count',
            style: TextStyle(color: textColor, fontSize: 24.sp),
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          label,
          style: TextStyle(color: textColor, fontSize: 16.sp),
        ),
      ],
    );
  }
}
