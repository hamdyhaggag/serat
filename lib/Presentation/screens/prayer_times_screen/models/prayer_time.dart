import 'package:flutter/material.dart';

/// A model class representing a prayer time with its associated data.
/// This class is immutable to ensure thread safety and prevent accidental modifications.
@immutable
class PrayerTime {
  /// The name of the prayer in Arabic
  final String name;

  /// The time of the prayer in 24-hour format (HH:mm)
  final String time;

  /// The icon representing the prayer
  final IconData icon;

  /// Whether this is the next prayer
  final bool isNext;

  /// Creates a new [PrayerTime] instance.
  const PrayerTime({
    required this.name,
    required this.time,
    required this.icon,
    this.isNext = false,
  });

  /// Creates a copy of this [PrayerTime] with the given fields replaced with the new values.
  PrayerTime copyWith({
    String? name,
    String? time,
    IconData? icon,
    bool? isNext,
  }) {
    return PrayerTime(
      name: name ?? this.name,
      time: time ?? this.time,
      icon: icon ?? this.icon,
      isNext: isNext ?? this.isNext,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PrayerTime &&
        other.name == name &&
        other.time == time &&
        other.icon == icon &&
        other.isNext == isNext;
  }

  @override
  int get hashCode => Object.hash(name, time, icon, isNext);

  @override
  String toString() => 'PrayerTime(name: $name, time: $time, isNext: $isNext)';
}
