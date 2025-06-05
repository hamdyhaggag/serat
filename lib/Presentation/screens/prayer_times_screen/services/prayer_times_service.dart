import 'dart:async';
import 'package:dio/dio.dart';
import 'package:serat/Presentation/screens/prayer_times_screen/constants/prayer_times_constants.dart';
import 'package:serat/Presentation/screens/prayer_times_screen/models/location.dart';
import 'package:serat/shared/services/notification_service.dart';

/// Service class for handling prayer times related operations.
class PrayerTimesService {
  final Dio _dio;
  final NotificationService _notificationService;
  final String _baseUrl = 'http://api.aladhan.com/v1';

  /// Creates a new [PrayerTimesService] instance.
  PrayerTimesService({
    required Dio dio,
    required NotificationService notificationService,
  })  : _dio = dio,
        _notificationService = notificationService;

  /// Fetches prayer times for a given location and date.
  ///
  /// Returns a map of prayer names to their times.
  /// Throws an exception if the request fails.
  Future<Map<String, String>> getPrayerTimes({
    required Location location,
    required DateTime date,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/timings/${date.millisecondsSinceEpoch ~/ 1000}',
        queryParameters: {
          'latitude': location.latitude,
          'longitude': location.longitude,
          'method': PrayerTimesConstants.calculationMethod,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch prayer times');
      }

      final data = response.data['data'];
      if (data == null || data['timings'] == null) {
        throw Exception('Invalid response format');
      }

      return Map<String, String>.from(data['timings']);
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch prayer times: $e');
    }
  }

  /// Schedules notifications for all prayer times.
  ///
  /// Throws an exception if scheduling fails.
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
  ///
  /// Throws an exception if cancellation fails.
  Future<void> cancelPrayerNotifications() async {
    try {
      await _notificationService.cancelAllNotifications();
    } catch (e) {
      throw Exception('Failed to cancel notifications: $e');
    }
  }

  /// Gets the next prayer time based on the current time.
  ///
  /// Returns a tuple containing the prayer name and time.
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
  ///
  /// Returns a [Duration] object representing the time until the next prayer.
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
