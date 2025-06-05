import 'package:flutter/material.dart';

/// Constants used throughout the prayer times feature.
class PrayerTimesConstants {
  /// Prayer names in Arabic.
  static const Map<String, String> prayerNames = {
    'Fajr': 'الفجر',
    'Sunrise': 'الشروق',
    'Dhuhr': 'الظهر',
    'Asr': 'العصر',
    'Maghrib': 'المغرب',
    'Isha': 'العشاء',
  };

  /// Icons for each prayer.
  static final Map<String, IconData> prayerIcons = {
    'Fajr': Icons.nightlight_round,
    'Sunrise': Icons.wb_sunny_outlined,
    'Dhuhr': Icons.wb_sunny,
    'Asr': Icons.wb_sunny_rounded,
    'Maghrib': Icons.nightlight_round,
    'Isha': Icons.nightlight_round,
  };

  /// Calculation method for prayer times.
  static const String calculationMethod = 'MWL';

  /// UI Constants
  static const double cardWidth = 160.0;
  static const double cardHeight = 120.0;
  static const double cardMargin = 8.0;
  static const double cardPadding = 16.0;
  static const double iconSize = 32.0;
  static const double prayerNameFontSize = 16.0;
  static const double prayerTimeFontSize = 20.0;
  static const double countdownFontSize = 18.0;

  /// Animation Constants
  static const Duration fadeAnimationDuration = Duration(milliseconds: 500);
  static const Duration countdownUpdateInterval = Duration(seconds: 1);

  /// Notification Constants
  static const String notificationChannelId = 'prayer_times_channel';
  static const String notificationChannelName = 'Prayer Times';
  static const String notificationChannelDescription =
      'Notifications for prayer times';

  /// Error Messages
  static const String locationError = 'فشل في الحصول على الموقع';
  static const String networkError = 'فشل في الاتصال بالإنترنت';
  static const String apiError = 'فشل في جلب مواقيت الصلاة';
}
