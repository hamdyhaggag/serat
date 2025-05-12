import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as dev;
import '../models/quran_chapter.dart';
import '../models/quran_verse.dart';
import 'cache_service.dart';

class QuranService {
  static const String _baseUrl = 'https://api.alquran.cloud/v1';
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

      dev.log('Fetching Quran chapters from $_baseUrl/surah');
      final response = await http.get(Uri.parse('$_baseUrl/surah'));

      dev.log('Response status code: ${response.statusCode}');
      dev.log('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 200 && data['status'] == 'OK') {
          final List<dynamic> chapters = data['data'];
          final chaptersList = chapters
              .map((chapter) => QuranChapter.fromJson(chapter))
              .toList();
          
          // Cache the chapters
          await _cacheService.cacheChapters(chaptersList);
          
          return chaptersList;
        } else {
          throw Exception('API returned an error: ${data['status']}');
        }
      } else {
        throw Exception('Failed to load chapters: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      dev.log('Error fetching Quran chapters: $e');
      dev.log('Stack trace: $stackTrace');
      throw Exception('Error fetching Quran chapters: $e');
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

      dev.log(
        'Fetching verses for chapter $chapterNumber from $_baseUrl/surah/$chapterNumber/ar.alafasy',
      );
      final response = await http.get(
        Uri.parse('$_baseUrl/surah/$chapterNumber/ar.alafasy'),
      );

      dev.log('Response status code: ${response.statusCode}');
      dev.log('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 200 && data['status'] == 'OK') {
          final List<dynamic> verses = data['data']['ayahs'];
          final versesList = verses.map((verse) => QuranVerse.fromJson(verse)).toList();
          
          // Cache the verses
          await _cacheService.cacheChapterVerses(chapterNumber, versesList);
          
          return versesList;
        } else {
          throw Exception('API returned an error: ${data['status']}');
        }
      } else {
        throw Exception('Failed to load verses: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      dev.log('Error fetching Quran verses: $e');
      dev.log('Stack trace: $stackTrace');
      throw Exception('Error fetching Quran verses: $e');
    }
  }
}
