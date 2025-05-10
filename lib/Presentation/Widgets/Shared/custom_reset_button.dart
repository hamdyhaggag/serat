import 'package:flutter/material.dart';
import 'package:serat/Presentation/Config/constants/app_text.dart';
import 'package:serat/Presentation/Config/constants/colors.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.verticalPadding,
    this.horizontalPadding,
  });
  final String title;
  final Function() onPressed;
  final double? verticalPadding;
  final double? horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: verticalPadding ?? 13,
        horizontal: horizontalPadding ?? 13,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: MaterialButton(
          color: isDarkMode ? const Color(0xff0c8ee1) : AppColors.primaryColor,
          onPressed: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Center(
              child: AppText(
                title,
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'DIN',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
