import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weekly_prayer_times.dart';
import '../models/location.dart';

/// Service class for caching prayer times data with offline support.
class PrayerTimesCacheService {
  static const String _weeklyCacheKey = 'weekly_prayer_times_cache';
  static const String _locationCacheKey = 'last_location_cache';
  static const String _lastUpdateKey = 'prayer_times_last_update';
  static const Duration _cacheValidityDuration = Duration(days: 7);

  static PrayerTimesCacheService? _instance;
  SharedPreferences? _prefs;

  PrayerTimesCacheService._();

  /// Gets the singleton instance of [PrayerTimesCacheService].
  static PrayerTimesCacheService get instance {
    _instance ??= PrayerTimesCacheService._();
    return _instance!;
  }

  /// Initializes the cache service.
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Caches weekly prayer times data.
  Future<void> cacheWeeklyPrayerTimes(WeeklyPrayerTimes weeklyData) async {
    await _ensureInitialized();

    try {
      final cacheData = {
        'data': weeklyData.toJson(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      await _prefs!.setString(_weeklyCacheKey, jsonEncode(cacheData));
      await _prefs!.setString(_lastUpdateKey, DateTime.now().toIso8601String());

      print(
          'Prayer times cached successfully for week starting: ${weeklyData.weekStart}');
    } catch (e) {
      print('Error caching prayer times: $e');
      throw Exception('Failed to cache prayer times: $e');
    }
  }

  /// Retrieves cached weekly prayer times.
  Future<WeeklyPrayerTimes?> getCachedWeeklyPrayerTimes() async {
    await _ensureInitialized();

    try {
      final cachedString = _prefs!.getString(_weeklyCacheKey);
      if (cachedString == null) return null;

      final cacheData = jsonDecode(cachedString) as Map<String, dynamic>;
      final timestamp = cacheData['timestamp'] as int;
      final now = DateTime.now().millisecondsSinceEpoch;

      // Check if cache is expired
      if (now - timestamp > _cacheValidityDuration.inMilliseconds) {
        print('Prayer times cache expired, clearing...');
        await clearCache();
        return null;
      }

      final weeklyData = WeeklyPrayerTimes.fromJson(cacheData['data']);

      // Additional validation: check if data is for current week
      if (!weeklyData.isCurrentWeek) {
        print('Cached data is not for current week, clearing...');
        await clearCache();
        return null;
      }

      print(
          'Retrieved cached prayer times for week starting: ${weeklyData.weekStart}');
      return weeklyData;
    } catch (e) {
      print('Error reading cached prayer times: $e');
      await clearCache();
      return null;
    }
  }

  /// Gets prayer times for today from cache.
  Future<Map<String, String>?> getTodayPrayerTimes() async {
    final weeklyData = await getCachedWeeklyPrayerTimes();
    if (weeklyData == null) return null;

    final todayData = weeklyData.getTodayPrayerTimes();
    return todayData?.timings;
  }

  /// Gets prayer times for a specific date from cache.
  Future<Map<String, String>?> getPrayerTimesForDate(DateTime date) async {
    final weeklyData = await getCachedWeeklyPrayerTimes();
    if (weeklyData == null) return null;

    final dateData = weeklyData.getPrayerTimesForDate(date);
    return dateData?.timings;
  }

  /// Caches the last known location.
  Future<void> cacheLocation(Location location) async {
    await _ensureInitialized();

    try {
      final locationData = {
        'location': location.toJson(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      await _prefs!.setString(_locationCacheKey, jsonEncode(locationData));
      print('Location cached: ${location.name}');
    } catch (e) {
      print('Error caching location: $e');
    }
  }

  /// Retrieves the last cached location.
  Future<Location?> getCachedLocation() async {
    await _ensureInitialized();

    try {
      final cachedString = _prefs!.getString(_locationCacheKey);
      if (cachedString == null) return null;

      final cacheData = jsonDecode(cachedString) as Map<String, dynamic>;
      final timestamp = cacheData['timestamp'] as int;
      final now = DateTime.now().millisecondsSinceEpoch;

      // Location cache is valid for 30 days
      if (now - timestamp > const Duration(days: 30).inMilliseconds) {
        print('Location cache expired, clearing...');
        await _prefs!.remove(_locationCacheKey);
        return null;
      }

      final location = Location.fromJson(cacheData['location']);
      print('Retrieved cached location: ${location.name}');
      return location;
    } catch (e) {
      print('Error reading cached location: $e');
      await _prefs!.remove(_locationCacheKey);
      return null;
    }
  }

  /// Checks if there's valid cached data available.
  Future<bool> hasValidCache() async {
    final weeklyData = await getCachedWeeklyPrayerTimes();
    return weeklyData != null && weeklyData.isValid;
  }

  /// Checks if the cached data is for the current week.
  Future<bool> isCurrentWeekCached() async {
    final weeklyData = await getCachedWeeklyPrayerTimes();
    return weeklyData != null && weeklyData.isCurrentWeek;
  }

  /// Gets the last update timestamp.
  DateTime? getLastUpdateTime() {
    try {
      final lastUpdateString = _prefs?.getString(_lastUpdateKey);
      if (lastUpdateString == null) return null;
      return DateTime.parse(lastUpdateString);
    } catch (e) {
      print('Error parsing last update time: $e');
      return null;
    }
  }

  /// Clears all cached prayer times data.
  Future<void> clearCache() async {
    await _ensureInitialized();

    try {
      await _prefs!.remove(_weeklyCacheKey);
      await _prefs!.remove(_lastUpdateKey);
      print('Prayer times cache cleared');
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  /// Clears location cache.
  Future<void> clearLocationCache() async {
    await _ensureInitialized();

    try {
      await _prefs!.remove(_locationCacheKey);
      print('Location cache cleared');
    } catch (e) {
      print('Error clearing location cache: $e');
    }
  }

  /// Clears all cache data.
  Future<void> clearAllCache() async {
    await clearCache();
    await clearLocationCache();
  }

  /// Gets cache statistics for debugging.
  Map<String, dynamic> getCacheStats() {
    final lastUpdate = getLastUpdateTime();
    final hasWeeklyCache = _prefs?.containsKey(_weeklyCacheKey) ?? false;
    final hasLocationCache = _prefs?.containsKey(_locationCacheKey) ?? false;

    return {
      'hasWeeklyCache': hasWeeklyCache,
      'hasLocationCache': hasLocationCache,
      'lastUpdate': lastUpdate?.toIso8601String(),
      'daysSinceLastUpdate': lastUpdate != null
          ? DateTime.now().difference(lastUpdate).inDays
          : null,
    };
  }

  /// Ensures the service is initialized.
  Future<void> _ensureInitialized() async {
    if (_prefs == null) {
      await init();
    }
  }
}
