import 'package:flutter/foundation.dart';
import 'location.dart';

/// A model class representing prayer times for a specific date.
@immutable
class DailyPrayerTimes {
  /// The date for these prayer times
  final DateTime date;

  /// Map of prayer names to their times (e.g., 'Fajr' -> '05:30')
  final Map<String, String> timings;

  /// The location these prayer times are for
  final Location location;

  /// Creates a new [DailyPrayerTimes] instance.
  const DailyPrayerTimes({
    required this.date,
    required this.timings,
    required this.location,
  });

  /// Creates a copy of this [DailyPrayerTimes] with the given fields replaced with the new values.
  DailyPrayerTimes copyWith({
    DateTime? date,
    Map<String, String>? timings,
    Location? location,
  }) {
    return DailyPrayerTimes(
      date: date ?? this.date,
      timings: timings ?? this.timings,
      location: location ?? this.location,
    );
  }

  /// Creates a [DailyPrayerTimes] from a JSON map.
  factory DailyPrayerTimes.fromJson(Map<String, dynamic> json) {
    return DailyPrayerTimes(
      date: DateTime.parse(json['date'] as String),
      timings: Map<String, String>.from(json['timings'] as Map),
      location: Location.fromJson(json['location'] as Map<String, dynamic>),
    );
  }

  /// Converts this [DailyPrayerTimes] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'timings': timings,
      'location': location.toJson(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyPrayerTimes &&
        other.date == date &&
        mapEquals(other.timings, timings) &&
        other.location == location;
  }

  @override
  int get hashCode => Object.hash(date, timings, location);

  @override
  String toString() => 'DailyPrayerTimes(date: $date, timings: $timings)';
}

/// A model class representing prayer times for a week.
@immutable
class WeeklyPrayerTimes {
  /// The start date of the week (Monday)
  final DateTime weekStart;

  /// List of daily prayer times for the week
  final List<DailyPrayerTimes> dailyTimes;

  /// The location these prayer times are for
  final Location location;

  /// When this data was last updated
  final DateTime lastUpdated;

  /// Creates a new [WeeklyPrayerTimes] instance.
  const WeeklyPrayerTimes({
    required this.weekStart,
    required this.dailyTimes,
    required this.location,
    required this.lastUpdated,
  });

  /// Creates a copy of this [WeeklyPrayerTimes] with the given fields replaced with the new values.
  WeeklyPrayerTimes copyWith({
    DateTime? weekStart,
    List<DailyPrayerTimes>? dailyTimes,
    Location? location,
    DateTime? lastUpdated,
  }) {
    return WeeklyPrayerTimes(
      weekStart: weekStart ?? this.weekStart,
      dailyTimes: dailyTimes ?? this.dailyTimes,
      location: location ?? this.location,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Creates a [WeeklyPrayerTimes] from a JSON map.
  factory WeeklyPrayerTimes.fromJson(Map<String, dynamic> json) {
    return WeeklyPrayerTimes(
      weekStart: DateTime.parse(json['weekStart'] as String),
      dailyTimes: (json['dailyTimes'] as List)
          .map(
              (item) => DailyPrayerTimes.fromJson(item as Map<String, dynamic>))
          .toList(),
      location: Location.fromJson(json['location'] as Map<String, dynamic>),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  /// Converts this [WeeklyPrayerTimes] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'weekStart': weekStart.toIso8601String(),
      'dailyTimes': dailyTimes.map((daily) => daily.toJson()).toList(),
      'location': location.toJson(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  /// Gets prayer times for a specific date
  DailyPrayerTimes? getPrayerTimesForDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return dailyTimes.firstWhere(
      (daily) =>
          DateTime(daily.date.year, daily.date.month, daily.date.day) ==
          normalizedDate,
      orElse: () => dailyTimes.first, // Fallback to first day if not found
    );
  }

  /// Gets prayer times for today
  DailyPrayerTimes? getTodayPrayerTimes() {
    return getPrayerTimesForDate(DateTime.now());
  }

  /// Checks if the data is still valid (not older than 7 days)
  bool get isValid {
    final now = DateTime.now();
    final difference = now.difference(lastUpdated);
    return difference.inDays < 7;
  }

  /// Checks if the data is for the current week
  bool get isCurrentWeek {
    final now = DateTime.now();
    final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
    final normalizedCurrentWeekStart = DateTime(
        currentWeekStart.year, currentWeekStart.month, currentWeekStart.day);
    final normalizedWeekStart =
        DateTime(weekStart.year, weekStart.month, weekStart.day);
    return normalizedCurrentWeekStart == normalizedWeekStart;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeeklyPrayerTimes &&
        other.weekStart == weekStart &&
        listEquals(other.dailyTimes, dailyTimes) &&
        other.location == location &&
        other.lastUpdated == lastUpdated;
  }

  @override
  int get hashCode => Object.hash(weekStart, dailyTimes, location, lastUpdated);

  @override
  String toString() =>
      'WeeklyPrayerTimes(weekStart: $weekStart, dailyTimes: ${dailyTimes.length})';
}
