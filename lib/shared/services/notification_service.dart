import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;
import 'dart:developer' as developer;

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

  Future<bool> requestPermissions() async {
    developer.log('Starting permission requests...',
        name: 'NotificationService');

    if (Platform.isAndroid) {
      // Request notification permission
      developer.log('Requesting notification permission...',
          name: 'NotificationService');
      final notificationStatus = await Permission.notification.request();
      developer.log(
          'Notification permission status: ${notificationStatus.name}',
          name: 'NotificationService');

      // Request exact alarm permission
      developer.log('Requesting exact alarm permission...',
          name: 'NotificationService');
      final exactAlarmStatus = await Permission.scheduleExactAlarm.request();
      developer.log('Exact alarm permission status: ${exactAlarmStatus.name}',
          name: 'NotificationService');

      // Request ignore battery optimization permission
      developer.log('Requesting battery optimization permission...',
          name: 'NotificationService');
      final batteryOptimizationStatus =
          await Permission.ignoreBatteryOptimizations.request();
      developer.log(
          'Battery optimization permission status: ${batteryOptimizationStatus.name}',
          name: 'NotificationService');

      final allGranted = notificationStatus.isGranted &&
          exactAlarmStatus.isGranted &&
          batteryOptimizationStatus.isGranted;

      developer.log('All permissions granted: $allGranted',
          name: 'NotificationService');
      return allGranted;
    }

    developer.log('Not on Android, skipping permission requests',
        name: 'NotificationService');
    return true;
  }

  Future<void> initialize() async {
    developer.log('Initializing notification service...',
        name: 'NotificationService');

    // Initialize timezones with explicit location
    tz.initializeTimeZones();

    // Get the current timezone offset
    final now = DateTime.now();
    final offset = now.timeZoneOffset;
    final isPositive = offset.isNegative ? '-' : '+';
    final hours = offset.inHours.abs();
    final minutes = (offset.inMinutes.abs() % 60);
    final timeZoneString =
        'UTC$isPositive${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';

    developer.log('Current timezone offset: $timeZoneString',
        name: 'NotificationService');

    // Use a default location that matches the current offset
    final location = tz.getLocation('Europe/Istanbul'); // This covers EEST
    tz.setLocalLocation(location);
    developer.log('Set local timezone to: ${location.name}',
        name: 'NotificationService');

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

    try {
      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
      developer.log('Notifications plugin initialized successfully',
          name: 'NotificationService');

      // Create notification channels for Android
      if (Platform.isAndroid) {
        developer.log('Creating Android notification channel...',
            name: 'NotificationService');
        await _notifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(
              const AndroidNotificationChannel(
                'prayer_times_channel',
                'Prayer Times',
                description: 'Notifications for prayer times',
                importance: Importance.max,
                playSound: true,
                enableVibration: true,
                showBadge: true,
                enableLights: true,
              ),
            );
        developer.log('Android notification channel created',
            name: 'NotificationService');
      }
    } catch (e) {
      developer.log('Error initializing notifications: $e',
          name: 'NotificationService', error: e);
      rethrow;
    }
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
      // Error handling without logging
    }
  }

  Future<void> schedulePrayerNotification({
    required String prayerName,
    required DateTime prayerTime,
    required int id,
  }) async {
    final now = DateTime.now();
    var scheduledTime = prayerTime;

    // If the prayer time has passed for today, schedule for tomorrow
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'prayer_times_channel',
      'Prayer Times',
      channelDescription: 'Notifications for prayer times',
      importance: Importance.max,
      priority: Priority.max,
      enableVibration: true,
      playSound: true,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
      showWhen: true,
      ticker: 'حان وقت الصلاة',
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
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> scheduleAllPrayerTimes(Map<String, String> prayerTimes) async {
    // Cancel existing notifications first
    await cancelAllNotifications();

    // Schedule new notifications
    int id = 1;
    for (var entry in prayerTimes.entries) {
      final timeParts = entry.value.split(':');
      final now = DateTime.now();
      final prayerTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );

      await schedulePrayerNotification(
        prayerName: entry.key,
        prayerTime: prayerTime,
        id: id++,
      );
    }
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<void> scheduleTestNotification() async {
    developer.log('Starting test notification scheduling...',
        name: 'NotificationService');

    // Request permissions first
    await requestPermissions();

    // Show immediate notification
    developer.log('Showing immediate test notification...',
        name: 'NotificationService');
    await _notifications.show(
      0,
      'إشعار تجريبي',
      'هذا إشعار فوري للتجربة',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'prayer_times_channel',
          'Prayer Times',
          channelDescription: 'Notifications for prayer times',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          enableLights: true,
          enableVibration: true,
          playSound: true,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
          visibility: NotificationVisibility.public,
          ticker: 'Prayer Time Notification',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
    developer.log('Immediate test notification shown',
        name: 'NotificationService');

    // Schedule delayed notification
    final now = tz.TZDateTime.now(tz.local);
    developer.log('Using timezone: ${tz.local.name}',
        name: 'NotificationService');

    // Cancel any existing scheduled notifications
    await _notifications.cancelAll();
    developer.log('Cancelled any existing scheduled notifications',
        name: 'NotificationService');

    // Schedule for 5 seconds from now
    final scheduledTime = now.add(const Duration(seconds: 5));
    developer.log('Current time in local timezone: $now',
        name: 'NotificationService');
    developer.log('Scheduling delayed notification for: $scheduledTime',
        name: 'NotificationService');

    await _notifications.zonedSchedule(
      1,
      'إشعار مجدول',
      'هذا إشعار مجدول للتجربة',
      scheduledTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'prayer_times_channel',
          'Prayer Times',
          channelDescription: 'Notifications for prayer times',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          enableLights: true,
          enableVibration: true,
          playSound: true,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
          visibility: NotificationVisibility.public,
          ticker: 'Prayer Time Notification',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
    developer.log('Delayed test notification scheduled successfully',
        name: 'NotificationService');
  }
}
