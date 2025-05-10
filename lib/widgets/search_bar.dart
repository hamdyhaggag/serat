import 'package:flutter/material.dart';
import 'package:serat/constants/app_theme.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isDarkMode;

  const CustomSearchBar({
    Key? key,
    required this.controller,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        textDirection: TextDirection.rtl,
        style: TextStyle(
          fontFamily: 'Cairo',
          color: isDarkMode ? Colors.white : AppTheme.textPrimaryColor,
        ),
        decoration: InputDecoration(
          hintText: 'ابحث عن ما تريد',
          hintTextDirection: TextDirection.rtl,
          hintStyle: TextStyle(
            fontFamily: 'Cairo',
            color: isDarkMode ? Colors.white70 : AppTheme.textSecondaryColor,
          ),
          border: InputBorder.none,
          prefixIcon: Icon(
            Icons.search,
            color: isDarkMode ? Colors.white70 : AppTheme.primaryColor,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 16,
          ),
        ),
      ),
    );
  }
}
