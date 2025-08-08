import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../constants/prayer_times_constants.dart';
import '../models/location.dart';
import '../models/weekly_prayer_times.dart';
import 'prayer_times_cache_service.dart';
import '../../../../shared/services/notification_service.dart';

/// Enhanced service class for handling prayer times with weekly caching and offline support.
class EnhancedPrayerTimesService {
  final Dio _dio;
  final NotificationService _notificationService;
  final PrayerTimesCacheService _cacheService;
  final String _baseUrl = 'http://api.aladhan.com/v1';

  /// Creates a new [EnhancedPrayerTimesService] instance.
  EnhancedPrayerTimesService({
    required Dio dio,
    required NotificationService notificationService,
  })  : _dio = dio,
        _notificationService = notificationService,
        _cacheService = PrayerTimesCacheService.instance;

  /// Initializes the service.
  Future<void> init() async {
    await _cacheService.init();
  }

  /// Gets prayer times for today with offline support.
  ///
  /// Returns cached data if available and valid, otherwise fetches new data.
  Future<Map<String, String>> getTodayPrayerTimes({
    required Location location,
    bool forceRefresh = false,
  }) async {
    try {
      // Check if we have valid cached data and don't need to force refresh
      if (!forceRefresh) {
        final cachedTimes = await _cacheService.getTodayPrayerTimes();
        if (cachedTimes != null) {
          print('Using cached prayer times for today');
          return cachedTimes;
        }
      }

      // Check internet connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        // No internet, try to get cached data even if expired
        final cachedTimes = await _cacheService.getTodayPrayerTimes();
        if (cachedTimes != null) {
          print('No internet connection, using cached prayer times');
          return cachedTimes;
        }
        throw Exception('No internet connection and no cached data available');
      }

      // Fetch fresh data
      final weeklyData = await _fetchWeeklyPrayerTimes(location);
      await _cacheService.cacheWeeklyPrayerTimes(weeklyData);
      await _cacheService.cacheLocation(location);

      final todayTimes = weeklyData.getTodayPrayerTimes();
      if (todayTimes != null) {
        return todayTimes.timings;
      }

      throw Exception('Failed to get today\'s prayer times');
    } catch (e) {
      print('Error getting today\'s prayer times: $e');
      rethrow;
    }
  }

  /// Gets prayer times for a specific date.
  Future<Map<String, String>> getPrayerTimesForDate({
    required Location location,
    required DateTime date,
    bool forceRefresh = false,
  }) async {
    try {
      // Check if we have valid cached data and don't need to force refresh
      if (!forceRefresh) {
        final cachedTimes = await _cacheService.getPrayerTimesForDate(date);
        if (cachedTimes != null) {
          print('Using cached prayer times for ${date.toIso8601String()}');
          return cachedTimes;
        }
      }

      // Check internet connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        // No internet, try to get cached data even if expired
        final cachedTimes = await _cacheService.getPrayerTimesForDate(date);
        if (cachedTimes != null) {
          print('No internet connection, using cached prayer times');
          return cachedTimes;
        }
        throw Exception('No internet connection and no cached data available');
      }

      // Fetch fresh data
      final weeklyData = await _fetchWeeklyPrayerTimes(location);
      await _cacheService.cacheWeeklyPrayerTimes(weeklyData);
      await _cacheService.cacheLocation(location);

      final dateTimes = weeklyData.getPrayerTimesForDate(date);
      if (dateTimes != null) {
        return dateTimes.timings;
      }

      throw Exception(
          'Failed to get prayer times for ${date.toIso8601String()}');
    } catch (e) {
      print('Error getting prayer times for date: $e');
      rethrow;
    }
  }

  /// Fetches weekly prayer times from the API.
  Future<WeeklyPrayerTimes> _fetchWeeklyPrayerTimes(Location location) async {
    try {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6));

      final List<DailyPrayerTimes> dailyTimes = [];

      // Fetch prayer times for each day of the week
      for (int i = 0; i < 7; i++) {
        final date = weekStart.add(Duration(days: i));
        final timings = await _fetchDailyPrayerTimes(location, date);

        dailyTimes.add(DailyPrayerTimes(
          date: date,
          timings: timings,
          location: location,
        ));

        // Add a small delay to avoid overwhelming the API
        if (i < 6) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }

      return WeeklyPrayerTimes(
        weekStart: weekStart,
        dailyTimes: dailyTimes,
        location: location,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      print('Error fetching weekly prayer times: $e');
      rethrow;
    }
  }

  /// Fetches prayer times for a specific date from the API.
  Future<Map<String, String>> _fetchDailyPrayerTimes(
    Location location,
    DateTime date,
  ) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/timings/${date.millisecondsSinceEpoch ~/ 1000}',
        queryParameters: {
          'latitude': location.latitude,
          'longitude': location.longitude,
          'method': PrayerTimesConstants.calculationMethod,
        },
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to fetch prayer times: HTTP ${response.statusCode}');
      }

      final data = response.data['data'];
      if (data == null || data['timings'] == null) {
        throw Exception('Invalid response format from API');
      }

      return Map<String, String>.from(data['timings']);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception(
            'Request timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection available.');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to fetch prayer times: $e');
    }
  }

  /// Gets the next prayer time based on the current time.
  (String, String) getNextPrayerTime(Map<String, String> prayerTimes) {
    final now = DateTime.now();
    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final sortedPrayers = prayerTimes.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    for (final prayer in sortedPrayers) {
      if (prayer.value.compareTo(currentTime) > 0) {
        return (prayer.key, prayer.value);
      }
    }

    // If no prayer time is found after current time, return the first prayer of the day
    return (sortedPrayers.first.key, sortedPrayers.first.value);
  }

  /// Calculates the duration until the next prayer.
  Duration getTimeUntilNextPrayer(String prayerTime) {
    final now = DateTime.now();
    final timeParts = prayerTime.split(':');
    final prayerDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );

    if (prayerDateTime.isBefore(now)) {
      return prayerDateTime.add(const Duration(days: 1)).difference(now);
    }

    return prayerDateTime.difference(now);
  }

  /// Schedules notifications for all prayer times.
  Future<void> schedulePrayerNotifications(
      Map<String, String> prayerTimes) async {
    try {
      await _notificationService.cancelAllNotifications();

      for (final entry in prayerTimes.entries) {
        final prayerName = PrayerTimesConstants.prayerNames[entry.key];
        if (prayerName != null) {
          final time = _parseTimeString(entry.value);
          if (time != null) {
            await _notificationService.schedulePrayerNotification(
              prayerName: prayerName,
              prayerTime: time,
              id: entry.key.hashCode,
            );
          }
        }
      }
    } catch (e) {
      throw Exception('Failed to schedule notifications: $e');
    }
  }

  /// Cancels all scheduled prayer notifications.
  Future<void> cancelPrayerNotifications() async {
    try {
      await _notificationService.cancelAllNotifications();
    } catch (e) {
      throw Exception('Failed to cancel notifications: $e');
    }
  }

  /// Gets cached location if available.
  Future<Location?> getCachedLocation() async {
    return await _cacheService.getCachedLocation();
  }

  /// Checks if there's valid cached data available.
  Future<bool> hasValidCache() async {
    return await _cacheService.hasValidCache();
  }

  /// Checks if the cached data is for the current week.
  Future<bool> isCurrentWeekCached() async {
    return await _cacheService.isCurrentWeekCached();
  }

  /// Gets cache statistics for debugging.
  Map<String, dynamic> getCacheStats() {
    return _cacheService.getCacheStats();
  }

  /// Clears all cached data.
  Future<void> clearCache() async {
    await _cacheService.clearAllCache();
  }

  /// Gets cached weekly prayer times.
  Future<WeeklyPrayerTimes?> getCachedWeeklyPrayerTimes() async {
    return await _cacheService.getCachedWeeklyPrayerTimes();
  }

  /// Parses a time string in HH:mm format to a DateTime object.
  DateTime? _parseTimeString(String time) {
    try {
      final parts = time.split(':');
      final now = DateTime.now();
      return DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
    } catch (e) {
      return null;
    }
  }
}
