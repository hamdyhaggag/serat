import 'package:flutter/material.dart';

class HadithSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final bool isDarkMode;

  const HadithSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'ابحث عن حديث...',
          hintStyle: TextStyle(
            color: isDarkMode ? Colors.white54 : Colors.black54,
            fontFamily: 'DIN',
          ),
          prefixIcon: Icon(
            Icons.search,
            color: isDarkMode ? Colors.white54 : Colors.black54,
          ),
          filled: true,
          fillColor: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontFamily: 'DIN',
        ),
      ),
    );
  }
}
