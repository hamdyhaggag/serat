/// Theme configuration for the professional Quran reader
/// Inspired by Madinah Mushaf design

import 'package:flutter/material.dart';

/// Quran reader theme modes
enum QuranReaderTheme {
  light,
  sepia,
  dark,
}

/// Color schemes for the Quran reader
class QuranReaderColors {
  // Light theme (Madinah Mushaf style)
  static const Color lightBackground = Color(0xFFFFFDF5);
  static const Color lightFrameColor = Color(0xFF2E7D32);
  static const Color lightTextColor = Color(0xFF1B1B1B);
  static const Color lightVerseNumberBg = Color(0xFF4CAF50);
  static const Color lightVerseNumberText = Colors.white;
  static const Color lightHeaderBg = Color(0xFFE8F5E9);
  static const Color lightSurahHeaderBg = Color(0xFF4CAF50);
  static const Color lightBismillahColor = Color(0xFF2E7D32);
  static const Color lightPageNumberBg = Color(0xFF4CAF50);
  static const Color lightDivider = Color(0xFFE0E0E0);

  // Sepia theme (warm reading)
  static const Color sepiaBackground = Color(0xFFF5EFE0);
  static const Color sepiaFrameColor = Color(0xFF8D6E63);
  static const Color sepiaTextColor = Color(0xFF4E342E);
  static const Color sepiaVerseNumberBg = Color(0xFF8D6E63);
  static const Color sepiaVerseNumberText = Colors.white;
  static const Color sepiaHeaderBg = Color(0xFFEFEBE9);
  static const Color sepiaSurahHeaderBg = Color(0xFF8D6E63);
  static const Color sepiaBismillahColor = Color(0xFF5D4037);
  static const Color sepiaPageNumberBg = Color(0xFF8D6E63);
  static const Color sepiaDivider = Color(0xFFD7CCC8);

  // Dark theme (night reading)
  static const Color darkBackground = Color(0xFF1A1A2E);
  static const Color darkFrameColor = Color(0xFFD4AF37);
  static const Color darkTextColor = Color(0xFFE0E0E0);
  static const Color darkVerseNumberBg = Color(0xFFD4AF37);
  static const Color darkVerseNumberText = Color(0xFF1A1A2E);
  static const Color darkHeaderBg = Color(0xFF2D2D44);
  static const Color darkSurahHeaderBg = Color(0xFFD4AF37);
  static const Color darkBismillahColor = Color(0xFFD4AF37);
  static const Color darkPageNumberBg = Color(0xFFD4AF37);
  static const Color darkDivider = Color(0xFF3D3D5C);

  /// Get colors based on theme
  static QuranThemeData getTheme(QuranReaderTheme theme) {
    switch (theme) {
      case QuranReaderTheme.light:
        return const QuranThemeData(
          background: lightBackground,
          frameColor: lightFrameColor,
          textColor: lightTextColor,
          verseNumberBg: lightVerseNumberBg,
          verseNumberText: lightVerseNumberText,
          headerBg: lightHeaderBg,
          surahHeaderBg: lightSurahHeaderBg,
          bismillahColor: lightBismillahColor,
          pageNumberBg: lightPageNumberBg,
          divider: lightDivider,
        );
      case QuranReaderTheme.sepia:
        return const QuranThemeData(
          background: sepiaBackground,
          frameColor: sepiaFrameColor,
          textColor: sepiaTextColor,
          verseNumberBg: sepiaVerseNumberBg,
          verseNumberText: sepiaVerseNumberText,
          headerBg: sepiaHeaderBg,
          surahHeaderBg: sepiaSurahHeaderBg,
          bismillahColor: sepiaBismillahColor,
          pageNumberBg: sepiaPageNumberBg,
          divider: sepiaDivider,
        );
      case QuranReaderTheme.dark:
        return const QuranThemeData(
          background: darkBackground,
          frameColor: darkFrameColor,
          textColor: darkTextColor,
          verseNumberBg: darkVerseNumberBg,
          verseNumberText: darkVerseNumberText,
          headerBg: darkHeaderBg,
          surahHeaderBg: darkSurahHeaderBg,
          bismillahColor: darkBismillahColor,
          pageNumberBg: darkPageNumberBg,
          divider: darkDivider,
        );
    }
  }
}

/// Theme data container
class QuranThemeData {
  final Color background;
  final Color frameColor;
  final Color textColor;
  final Color verseNumberBg;
  final Color verseNumberText;
  final Color headerBg;
  final Color surahHeaderBg;
  final Color bismillahColor;
  final Color pageNumberBg;
  final Color divider;

  const QuranThemeData({
    required this.background,
    required this.frameColor,
    required this.textColor,
    required this.verseNumberBg,
    required this.verseNumberText,
    required this.headerBg,
    required this.surahHeaderBg,
    required this.bismillahColor,
    required this.pageNumberBg,
    required this.divider,
  });
}

/// Typography settings for the Quran reader
class QuranTypography {
  // Using Amiri for main text (clearer than AmiriQuran)
  static const String quranFont = 'Amiri';
  static const String arabicFont = 'Amiri';
  static const String headerFont = 'DIN';

  static const double defaultFontSize = 24.0;
  static const double minFontSize = 18.0;
  static const double maxFontSize = 36.0;

  static TextStyle quranTextStyle({
    required double fontSize,
    required Color color,
  }) {
    return TextStyle(
      fontFamily: quranFont,
      fontSize: fontSize,
      color: color,
      height: 1.9, // Better line height for Arabic
      letterSpacing: 0,
      wordSpacing: 2,
      fontWeight: FontWeight.w400,
    );
  }

  static TextStyle headerTextStyle({
    required Color color,
    double fontSize = 16,
  }) {
    return TextStyle(
      fontFamily: headerFont,
      fontSize: fontSize,
      color: color,
      fontWeight: FontWeight.w600,
    );
  }

  static TextStyle surahNameStyle({
    required Color color,
    double fontSize = 20,
  }) {
    return TextStyle(
      fontFamily: arabicFont,
      fontSize: fontSize,
      color: color,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle bismillahStyle({
    required Color color,
    double fontSize = 26,
  }) {
    return TextStyle(
      fontFamily: quranFont,
      fontSize: fontSize,
      color: color,
      height: 1.8,
    );
  }
}
