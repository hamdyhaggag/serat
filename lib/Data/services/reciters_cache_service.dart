import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:serat/Business_Logic/Models/reciter_model.dart';

class RecitersCacheService {
  static const String _cacheKey = 'cached_reciters';
  static const Duration _cacheDuration = Duration(days: 7);
  ReciterModel? _cachedModel;
  bool _isLoading = false;

  Future<ReciterModel?> getCachedReciters() async {
    if (_cachedModel != null) {
      return _cachedModel;
    }

    if (_isLoading) {
      return null;
    }

    _isLoading = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_cacheKey);

      if (cachedData == null) {
        return null;
      }

      final Map<String, dynamic> jsonData = json.decode(cachedData);
      final timestamp = jsonData['timestamp'] as int;
      final now = DateTime.now().millisecondsSinceEpoch;

      // Check if cache is expired
      if (now - timestamp > _cacheDuration.inMilliseconds) {
        await prefs.remove(_cacheKey);
        return null;
      }

      _cachedModel = ReciterModel.fromJson(jsonData['data']);
      return _cachedModel;
    } catch (e) {
      print('Error loading cached reciters: $e');
      return null;
    } finally {
      _isLoading = false;
    }
  }

  Future<void> cacheReciters(ReciterModel model) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now().millisecondsSinceEpoch;
      final cacheData = {
        'timestamp': now,
        'data': {
          'reciters':
              model.reciters
                  .map(
                    (r) => {
                      'id': r.id,
                      'name': r.name,
                      'letter': r.letter,
                      'moshaf':
                          r.moshaf
                              .map(
                                (m) => {
                                  'id': m.id,
                                  'name': m.name,
                                  'server': m.server,
                                  'surah_total': m.surahTotal,
                                  'moshaf_type': m.moshafType,
                                  'surah_list': m.surahList,
                                },
                              )
                              .toList(),
                    },
                  )
                  .toList(),
        },
      };
      await prefs.setString(_cacheKey, json.encode(cacheData));
      _cachedModel = model;
    } catch (e) {
      print('Error caching reciters: $e');
    }
  }

  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      _cachedModel = null;
    } catch (e) {
      print('Error clearing reciters cache: $e');
    }
  }
}
