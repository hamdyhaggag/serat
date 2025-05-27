import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:serat/domain/models/hadith_model.dart';
import 'package:http/http.dart' as http;

class HadithService {
  static const String _cacheKey = 'cached_hadiths';
  static const Duration _cacheDuration = Duration(days: 7);

  Future<List<HadithModel>> getNawawiHadiths() async {
    try {
      // Try to get cached data first
      final cachedData = await _getCachedHadiths();
      if (cachedData != null) {
        return cachedData;
      }

      // If no cache or expired, load from assets
      final String jsonString = await rootBundle.loadString(
        'assets/nawawi_hadiths.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> hadithsData = jsonData['hadiths'] ?? [];

      final List<HadithModel> hadiths = [];
      for (var hadith in hadithsData) {
        hadiths.add(HadithModel(
          id: hadith['id'] ?? 0,
          hadithNumber: 'حديث ${hadith['number'] ?? ''}',
          hadithText: hadith['arabic'] ?? '',
          explanation: hadith['explanation'] ?? '',
          narrator: hadith['narrator'] ?? '',
          chapterName: hadith['chapter']?['arabic'] ??
              'باب ${hadith['chapterId'] ?? ''}',
          bookId: 'nawawi',
        ));
      }

      // Cache the new data
      await _cacheHadiths(hadiths);

      return hadiths;
    } catch (e) {
      // If loading from assets fails, try to get cached data as fallback
      final cachedData = await _getCachedHadiths();
      if (cachedData != null) {
        return cachedData;
      }
      throw Exception('Error loading hadiths: $e');
    }
  }

  Future<HadithModel> getHadithById(int id) async {
    try {
      final hadiths = await getNawawiHadiths();
      final hadith = hadiths.firstWhere((h) => h.id == id);
      return hadith;
    } catch (e) {
      throw Exception('Error fetching hadith: $e');
    }
  }

  Future<void> _cacheHadiths(List<HadithModel> hadiths) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now().millisecondsSinceEpoch;
      final cacheData = {
        'timestamp': now,
        'data': hadiths.map((h) => h.toJson()).toList(),
      };
      await prefs.setString(_cacheKey, json.encode(cacheData));
    } catch (e) {
      print('Error caching hadiths: $e');
    }
  }

  Future<List<HadithModel>?> _getCachedHadiths() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedString = prefs.getString(_cacheKey);

      if (cachedString == null) return null;

      final cacheData = json.decode(cachedString) as Map<String, dynamic>;
      final timestamp = cacheData['timestamp'] as int;
      final now = DateTime.now().millisecondsSinceEpoch;

      // Check if cache is expired
      if (now - timestamp > _cacheDuration.inMilliseconds) {
        await prefs.remove(_cacheKey);
        return null;
      }

      final List<dynamic> jsonData = cacheData['data'] as List<dynamic>;
      return jsonData.map((json) => HadithModel.fromJson(json)).toList();
    } catch (e) {
      print('Error reading cached hadiths: $e');
      return null;
    }
  }

  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
    } catch (e) {
      print('Error clearing hadith cache: $e');
    }
  }

  Future<List<HadithModel>> getRandomHadiths() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.alquran.cloud/v1/hadith/random'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final hadiths = <HadithModel>[];

        if (data['data'] != null) {
          final hadith = data['data'];
          hadiths.add(HadithModel(
            id: 0, // Using 0 as a placeholder since random hadiths don't have IDs
            hadithNumber: 'حديث عشوائي',
            hadithText: hadith['text'] ?? '',
            explanation: 'هذا حديث عشوائي من قاعدة بيانات الأحاديث',
            narrator: hadith['narrator'] ?? 'مصدر: API Hadith',
            chapterName: 'حديث عشوائي',
            bookId: 'random',
          ));
        }

        return hadiths;
      } else {
        throw Exception('Failed to load random hadiths');
      }
    } catch (e) {
      throw Exception('Error fetching random hadiths: $e');
    }
  }
}
