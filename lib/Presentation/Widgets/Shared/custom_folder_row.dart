import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:serat/Presentation/Config/constants/app_text.dart';
import 'package:serat/Presentation/Config/constants/colors.dart';

class CustomFolderRow extends StatelessWidget {
  const CustomFolderRow({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  FontAwesomeIcons.fileLines,
                  color: isDarkMode ? Colors.white : AppColors.primaryColor,
                ),
                SizedBox(width: 22.w),
                AppText(
                  title,
                  fontSize: 18,
                  fontFamily: 'DIN',
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white : AppColors.primaryColor,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 10.h),
        Container(height: 2.h, width: 420.w, color: colorWithOpacity),
      ],
    );
  }
}

Color colorWithOpacity = AppColors.primaryColor.withOpacity(0.2);
