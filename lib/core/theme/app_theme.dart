// App theme configuration
import 'package:flutter/material.dart';
import 'package:serat/Presentation/Config/constants/colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final lightPrimary = AppColors.primaryColor;
    const lightBackground = Color(0xFFF5F5F5);
    const lightSurface = Colors.white;

    return ThemeData(
      brightness: Brightness.light,
      primaryColor: lightPrimary,
      fontFamily: 'DIN',
      scaffoldBackgroundColor: lightBackground,
      cardColor: lightSurface,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(
            color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.black),
        bodyMedium: TextStyle(color: Colors.black54),
        titleLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
        backgroundColor: lightSurface,
        foregroundColor: lightPrimary,
      )),
      colorScheme: ColorScheme(
        primary: lightPrimary,
        secondary: Colors.greenAccent,
        surface: lightSurface,
        background: lightBackground,
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: Colors.black,
        onBackground: Colors.black,
        onError: Colors.white,
        brightness: Brightness.light,
      ),
    );
  }

  static ThemeData get darkTheme {
    final darkPrimary = AppColors.primaryColor;
    const darkBackground = Color(0xFF121212);
    const darkSurface = Color(0xFF1E1E1E);

    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: darkPrimary,
      fontFamily: 'DIN',
      scaffoldBackgroundColor: darkBackground,
      cardColor: darkSurface,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white70),
        titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
        backgroundColor: darkSurface,
        foregroundColor: darkPrimary,
      )),
      colorScheme: ColorScheme(
        primary: darkPrimary,
        secondary: Colors.tealAccent,
        surface: darkSurface,
        background: darkBackground,
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: Colors.white,
        onBackground: Colors.white,
        onError: Colors.black,
        brightness: Brightness.dark,
      ),
    );
  }
}
