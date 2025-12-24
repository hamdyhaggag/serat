/// Data models for the professional Quran reader
/// Based on Madinah Mushaf design

import 'package:serat/Core/models/quran_chapter.dart';

/// Represents a single page in the Mushaf
class QuranPageData {
  final int pageNumber;
  final int juzNumber;
  final int hizbNumber;
  final List<PageVerse> verses;
  final List<int>
      surahsOnPage; // List of surah numbers that appear on this page

  QuranPageData({
    required this.pageNumber,
    required this.juzNumber,
    required this.hizbNumber,
    required this.verses,
    required this.surahsOnPage,
  });

  /// Get the primary surah name for the page header
  String getPrimarySurahName(List<QuranChapter> chapters) {
    if (surahsOnPage.isEmpty) return '';
    final chapter = chapters.firstWhere(
      (c) => c.number == surahsOnPage.first,
      orElse: () => chapters.first,
    );
    return chapter.name['ar'] ?? '';
  }

  /// Check if a new surah starts on this page
  bool hasSurahStart(int surahNumber) {
    return verses
        .any((v) => v.surahNumber == surahNumber && v.verseNumber == 1);
  }
}

/// Represents a verse on a specific page
class PageVerse {
  final int surahNumber;
  final String surahName;
  final int verseNumber;
  final String arabicText;
  final int juz;
  final bool isSurahStart;
  final bool hasSajda;

  PageVerse({
    required this.surahNumber,
    required this.surahName,
    required this.verseNumber,
    required this.arabicText,
    required this.juz,
    this.isSurahStart = false,
    this.hasSajda = false,
  });
}

/// Utility class for Arabic number conversion
class ArabicNumbers {
  static const Map<String, String> _arabicDigits = {
    '0': '٠',
    '1': '١',
    '2': '٢',
    '3': '٣',
    '4': '٤',
    '5': '٥',
    '6': '٦',
    '7': '٧',
    '8': '٨',
    '9': '٩',
  };

  static String convert(int number) {
    return number.toString().split('').map((digit) {
      return _arabicDigits[digit] ?? digit;
    }).join();
  }

  static String getJuzName(int juz) {
    return 'الجزء ${convert(juz)}';
  }

  static String getHizbName(int hizb) {
    return 'الحزب ${convert(hizb)}';
  }

  static String getPageNumber(int page) {
    return convert(page);
  }
}

/// Juz information for header display
class JuzInfo {
  static const Map<int, String> juzNames = {
    1: 'الأول',
    2: 'الثاني',
    3: 'الثالث',
    4: 'الرابع',
    5: 'الخامس',
    6: 'السادس',
    7: 'السابع',
    8: 'الثامن',
    9: 'التاسع',
    10: 'العاشر',
    11: 'الحادي عشر',
    12: 'الثاني عشر',
    13: 'الثالث عشر',
    14: 'الرابع عشر',
    15: 'الخامس عشر',
    16: 'السادس عشر',
    17: 'السابع عشر',
    18: 'الثامن عشر',
    19: 'التاسع عشر',
    20: 'العشرون',
    21: 'الحادي والعشرون',
    22: 'الثاني والعشرون',
    23: 'الثالث والعشرون',
    24: 'الرابع والعشرون',
    25: 'الخامس والعشرون',
    26: 'السادس والعشرون',
    27: 'السابع والعشرون',
    28: 'الثامن والعشرون',
    29: 'التاسع والعشرون',
    30: 'الثلاثون',
  };

  static String getJuzTitle(int juz) {
    return 'الجزء ${juzNames[juz] ?? convert(juz)}';
  }

  static String convert(int number) {
    return ArabicNumbers.convert(number);
  }
}
