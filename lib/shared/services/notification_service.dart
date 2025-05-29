import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const int _radioNotificationId = 1000;
  String? _currentStation;
  bool? _isPlaying;

  // Callback function type for notification actions
  static Function(bool)? onPlayPauseToggled;

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    onPlayPauseToggled?.call(true);
  }

  Future<void> showRadioNotification({
    required String stationName,
    required bool isPlaying,
  }) async {
    // Don't update if state hasn't changed
    if (_currentStation == stationName && _isPlaying == isPlaying) {
      return;
    }

    _currentStation = stationName;
    _isPlaying = isPlaying;

    const androidDetails = AndroidNotificationDetails(
      'radio_channel',
      'Radio Player',
      channelDescription: 'Notifications for radio player',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: false,
      playSound: false,
      ongoing: true,
      category: AndroidNotificationCategory.transport,
      visibility: NotificationVisibility.public,
      showWhen: false,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: false,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notifications.show(
        _radioNotificationId,
        stationName,
        isPlaying ? 'جاري التشغيل' : 'متوقف',
        details,
      );
    } catch (e) {
      print('[NotificationService] Error showing notification: $e');
    }
  }

  Future<void> schedulePrayerNotification({
    required String prayerName,
    required DateTime prayerTime,
    required int id,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'prayer_times_channel',
      'Prayer Times',
      channelDescription: 'Notifications for prayer times',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      'حان وقت الصلاة',
      'حان وقت صلاة $prayerName',
      tz.TZDateTime.from(prayerTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
