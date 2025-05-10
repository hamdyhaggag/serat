import 'package:flutter/material.dart';

/// App theme constants including colors and text styles
class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF137058);
  static const Color primaryLightColor = Color(0xFF81C784);
  static const Color primaryDarkColor = Color(0xFF1B5E20);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkCardColor = Color(0xFF1E1E1E);

  // Text Styles
  static const TextStyle titleStyle = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 18,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 16,
  );

  static const TextStyle captionStyle = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 14,
    color: textSecondaryColor,
  );

  // Input Decoration
  static InputDecoration getInputDecoration({
    required String labelText,
    bool isDarkMode = false,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(
        fontFamily: 'Cairo',
        color: isDarkMode ? Colors.white70 : textSecondaryColor,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
    );
  }

  // Button Styles
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    padding: const EdgeInsets.symmetric(vertical: 14),
  );
}
