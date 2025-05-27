import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:developer' as dev;
import '../models/quran_chapter.dart';
import '../models/quran_verse.dart';
import 'cache_service.dart';

class QuranService {
  static const String _quranPath = 'assets/data/quran.json';
  final CacheService _cacheService;

  QuranService(this._cacheService);

  Future<List<QuranChapter>> getChapters() async {
    try {
      // Try to get cached chapters first
      final cachedChapters = _cacheService.getCachedChapters();
      if (cachedChapters != null) {
        dev.log('Using cached Quran chapters');
        return cachedChapters;
      }

      dev.log('Loading Quran data from $_quranPath');
      final String jsonString = await rootBundle.loadString(_quranPath);
      final List<dynamic> jsonData = json.decode(jsonString);

      final chaptersList =
          jsonData.map((chapter) => QuranChapter.fromJson(chapter)).toList();

      // Cache the chapters
      await _cacheService.cacheChapters(chaptersList);

      return chaptersList;
    } catch (e, stackTrace) {
      dev.log('Error loading Quran data: $e');
      dev.log('Stack trace: $stackTrace');
      throw Exception('Error loading Quran data: $e');
    }
  }

  Future<List<QuranVerse>> getChapterVerses(int chapterNumber) async {
    try {
      // Try to get cached verses first
      final cachedVerses = _cacheService.getCachedChapterVerses(chapterNumber);
      if (cachedVerses != null) {
        dev.log('Using cached verses for chapter $chapterNumber');
        return cachedVerses;
      }

      dev.log('Loading Quran data from $_quranPath');
      final String jsonString = await rootBundle.loadString(_quranPath);
      final List<dynamic> jsonData = json.decode(jsonString);

      // Find the chapter with the matching number
      final chapter = jsonData.firstWhere(
        (chapter) => chapter['number'] == chapterNumber,
        orElse: () => throw Exception('Chapter $chapterNumber not found'),
      );

      final verses = (chapter['verses'] as List)
          .map((verse) => QuranVerse.fromJson(verse))
          .toList();

      // Cache the verses
      await _cacheService.cacheChapterVerses(chapterNumber, verses);

      return verses;
    } catch (e, stackTrace) {
      dev.log('Error loading Quran verses: $e');
      dev.log('Stack trace: $stackTrace');
      throw Exception('Error loading Quran verses: $e');
    }
  }
}
