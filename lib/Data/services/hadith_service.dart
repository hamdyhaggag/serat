import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:serat/domain/models/hadith_model.dart';

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
      final List<dynamic> jsonData = json.decode(jsonString);
      final hadiths =
          jsonData.map((json) => HadithModel.fromJson(json)).toList();

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
}
