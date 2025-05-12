import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quran_chapter.dart';
import '../models/quran_verse.dart';

class CacheService {
  static const String _chaptersKey = 'quran_chapters';
  static const String _versesPrefix = 'quran_verses_';

  final SharedPreferences _prefs;

  CacheService(this._prefs);

  // Cache chapters
  Future<void> cacheChapters(List<QuranChapter> chapters) async {
    final chaptersJson = chapters.map((chapter) => chapter.toJson()).toList();
    await _prefs.setString(_chaptersKey, jsonEncode(chaptersJson));
  }

  // Get cached chapters
  List<QuranChapter>? getCachedChapters() {
    final chaptersJson = _prefs.getString(_chaptersKey);
    if (chaptersJson == null) return null;

    final List<dynamic> decoded = jsonDecode(chaptersJson);
    return decoded.map((json) => QuranChapter.fromJson(json)).toList();
  }

  // Cache verses for a specific chapter
  Future<void> cacheChapterVerses(
    int chapterNumber,
    List<QuranVerse> verses,
  ) async {
    final versesJson = verses.map((verse) => verse.toJson()).toList();
    await _prefs.setString(
      '$_versesPrefix$chapterNumber',
      jsonEncode(versesJson),
    );
  }

  // Get cached verses for a specific chapter
  List<QuranVerse>? getCachedChapterVerses(int chapterNumber) {
    final versesJson = _prefs.getString('$_versesPrefix$chapterNumber');
    if (versesJson == null) return null;

    final List<dynamic> decoded = jsonDecode(versesJson);
    return decoded.map((json) => QuranVerse.fromJson(json)).toList();
  }

  // Clear all cached Quran data
  Future<void> clearQuranCache() async {
    await _prefs.remove(_chaptersKey);
    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_versesPrefix)) {
        await _prefs.remove(key);
      }
    }
  }
}
