import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class RowWithTextAndIcon extends StatelessWidget {
  final String text;
  final IconData icon;
  final Widget? widget;
  final void Function()? onTap;

  const RowWithTextAndIcon(
    this.text,
    this.icon, {
    super.key,
    this.widget,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          AppText(
            text,
            fontSize: 17,
            fontFamily: 'DIN',
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.white : AppColors.primaryColor,
          ),
          SizedBox(width: 20.w),
          Icon(icon, color: isDarkMode ? Colors.white : AppColors.primaryColor),
          SizedBox(width: 16.0.w),
        ],
      ),
    );
  }
}
