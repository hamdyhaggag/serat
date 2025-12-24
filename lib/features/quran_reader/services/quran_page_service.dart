/// Service for managing Quran pages data
/// Handles page layout, verse grouping, and data preparation

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:serat/Core/models/quran_chapter.dart';
import '../data/quran_page_data.dart';

class QuranPageService {
  static const String _quranPath = 'assets/data/quran.json';

  List<QuranChapter>? _chapters;
  Map<int, QuranPageData>? _pagesCache;

  /// Load all Quran chapters from JSON
  Future<List<QuranChapter>> loadChapters() async {
    if (_chapters != null) return _chapters!;

    final String jsonString = await rootBundle.loadString(_quranPath);
    final List<dynamic> jsonData = json.decode(jsonString);
    _chapters =
        jsonData.map((chapter) => QuranChapter.fromJson(chapter)).toList();
    return _chapters!;
  }

  /// Get all chapters
  List<QuranChapter> get chapters => _chapters ?? [];

  /// Get chapter by number
  QuranChapter? getChapter(int number) {
    if (_chapters == null) return null;
    return _chapters!.firstWhere(
      (c) => c.number == number,
      orElse: () => _chapters!.first,
    );
  }

  /// Build page data for a specific page number
  Future<QuranPageData> getPageData(int pageNumber) async {
    await loadChapters();

    if (_pagesCache != null && _pagesCache!.containsKey(pageNumber)) {
      return _pagesCache![pageNumber]!;
    }

    final verses = <PageVerse>[];
    final surahsOnPage = <int>{};
    int juzNumber = 1;
    int hizbNumber = 1;

    for (final chapter in _chapters!) {
      for (final verse in chapter.verses) {
        if (verse.page == pageNumber) {
          juzNumber = verse.juz;
          hizbNumber = _calculateHizb(verse.juz, pageNumber);

          verses.add(PageVerse(
            surahNumber: chapter.number,
            surahName: chapter.name['ar'] ?? '',
            verseNumber: verse.number,
            arabicText: verse.text['ar'] ?? '',
            juz: verse.juz,
            isSurahStart: verse.number == 1,
            hasSajda: verse.sajda != null,
          ));

          surahsOnPage.add(chapter.number);
        }
      }
    }

    final pageData = QuranPageData(
      pageNumber: pageNumber,
      juzNumber: juzNumber,
      hizbNumber: hizbNumber,
      verses: verses,
      surahsOnPage: surahsOnPage.toList(),
    );

    // Cache the page
    _pagesCache ??= {};
    _pagesCache![pageNumber] = pageData;

    return pageData;
  }

  /// Get all verses for a page grouped by surah
  Future<Map<int, List<PageVerse>>> getVersesGroupedBySurah(
      int pageNumber) async {
    final pageData = await getPageData(pageNumber);
    final grouped = <int, List<PageVerse>>{};

    for (final verse in pageData.verses) {
      grouped.putIfAbsent(verse.surahNumber, () => []).add(verse);
    }

    return grouped;
  }

  /// Calculate hizb number based on juz and page
  int _calculateHizb(int juz, int pageNumber) {
    // Each juz has 2 hizbs, each hizb has approximately 10 pages
    // This is a simplified calculation
    final hizbBase = (juz - 1) * 2;
    final juzStartPage = (juz - 1) * 20 + 1;
    final pageInJuz = pageNumber - juzStartPage;

    if (pageInJuz < 10) {
      return hizbBase + 1;
    } else {
      return hizbBase + 2;
    }
  }

  /// Get the first page of a surah
  Future<int> getSurahStartPage(int surahNumber) async {
    await loadChapters();

    final chapter = _chapters!.firstWhere(
      (c) => c.number == surahNumber,
      orElse: () => _chapters!.first,
    );

    if (chapter.verses.isNotEmpty) {
      return chapter.verses.first.page;
    }

    return 1;
  }

  /// Get total pages in Quran
  int get totalPages => 604;

  /// Get surah name by number
  String getSurahName(int surahNumber) {
    if (_chapters == null) return '';
    final chapter = _chapters!.firstWhere(
      (c) => c.number == surahNumber,
      orElse: () => _chapters!.first,
    );
    return chapter.name['ar'] ?? '';
  }

  /// Check if page contains start of a surah
  Future<bool> pageContainsSurahStart(int pageNumber) async {
    final pageData = await getPageData(pageNumber);
    return pageData.verses.any((v) => v.isSurahStart);
  }

  /// Get list of surahs that start on a specific page
  Future<List<int>> getSurahsStartingOnPage(int pageNumber) async {
    final pageData = await getPageData(pageNumber);
    return pageData.verses
        .where((v) => v.isSurahStart)
        .map((v) => v.surahNumber)
        .toList();
  }

  /// Clear cache
  void clearCache() {
    _pagesCache = null;
  }

  /// Preload pages around current page for smooth scrolling
  Future<void> preloadPages(int currentPage, {int range = 3}) async {
    for (int i = currentPage - range; i <= currentPage + range; i++) {
      if (i >= 1 && i <= totalPages) {
        await getPageData(i);
      }
    }
  }
}
