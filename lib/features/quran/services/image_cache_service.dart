import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ImageCacheService {
  static const String _imageCacheKey = 'surah_images_cache';
  static final ImageCacheService _instance = ImageCacheService._internal();
  late SharedPreferences _prefs;

  factory ImageCacheService() {
    return _instance;
  }

  ImageCacheService._internal();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> cacheImageUrl(int surahId, String imageUrl) async {
    final Map<String, dynamic> cache = _getCache();
    cache[surahId.toString()] = imageUrl;
    await _saveCache(cache);
  }

  String? getCachedImageUrl(int surahId) {
    final Map<String, dynamic> cache = _getCache();
    return cache[surahId.toString()];
  }

  Map<String, dynamic> _getCache() {
    final String? cacheString = _prefs.getString(_imageCacheKey);
    if (cacheString == null) return {};
    return Map<String, dynamic>.from(json.decode(cacheString));
  }

  Future<void> _saveCache(Map<String, dynamic> cache) async {
    await _prefs.setString(_imageCacheKey, json.encode(cache));
  }
}
