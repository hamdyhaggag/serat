import 'package:flutter/material.dart';

class AppTheme {
  // Primary colors
  static const Color primaryLight = Color(0xff137058); // Your primary green
  static const Color primaryDark =
      Color(0xff0d4d3d); // Darker shade for dark mode

  // Secondary colors
  static const Color secondaryLight = Color(0xFF4CAF50);
  static const Color secondaryDark = Color(0xFF388E3C);

  // Error colors
  static const Color errorLight = Color(0xFFE53935);
  static const Color errorDark = Color(0xFFD32F2F);

  // Success colors
  static const Color successLight = Color(0xFF43A047);
  static const Color successDark = Color(0xFF2E7D32);

  // Warning colors
  static const Color warningLight = Color(0xFFFFA000);
  static const Color warningDark = Color(0xFFF57C00);

  // Background colors
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);

  // Surface colors
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Text colors
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textPrimaryDark = Color(0xFFE0E0E0);

  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryLight,
    scaffoldBackgroundColor: backgroundLight,
    colorScheme: ColorScheme.light(
      primary: primaryLight,
      secondary: secondaryLight,
      error: errorLight,
      background: backgroundLight,
      surface: surfaceLight,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onError: Colors.white,
      onBackground: textPrimaryLight,
      onSurface: textPrimaryLight,
    ),
    cardTheme: CardTheme(
      color: surfaceLight,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryLight,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(
        color: textPrimaryLight,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: textPrimaryLight,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        color: textPrimaryLight,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: textSecondaryLight,
        fontSize: 14,
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryDark,
    scaffoldBackgroundColor: backgroundDark,
    colorScheme: ColorScheme.dark(
      primary: primaryDark,
      secondary: secondaryDark,
      error: errorDark,
      background: backgroundDark,
      surface: surfaceDark,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onError: Colors.white,
      onBackground: textPrimaryDark,
      onSurface: textPrimaryDark,
    ),
    cardTheme: CardTheme(
      color: surfaceDark,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryDark,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(
        color: textPrimaryDark,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: textPrimaryDark,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        color: textPrimaryDark,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: textSecondaryDark,
        fontSize: 14,
      ),
    ),
  );
}
