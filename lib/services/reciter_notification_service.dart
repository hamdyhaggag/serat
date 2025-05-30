import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

class ReciterNotificationService {
  static final ReciterNotificationService _instance =
      ReciterNotificationService._internal();
  factory ReciterNotificationService() => _instance;
  ReciterNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  VoidCallback? onStop;

  Future<void> initialize() async {
    try {
      developer.log('Initializing notification service',
          name: 'ReciterNotificationService');

      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
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
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      // Create notification channel for Android
      await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              'reciter_channel',
              'Reciter Notifications',
              description: 'Notifications for Quran recitations',
              importance: Importance.high,
              playSound: false,
              enableVibration: false,
              showBadge: true,
            ),
          );

      developer.log('Notification service initialized successfully',
          name: 'ReciterNotificationService');
    } catch (e) {
      developer.log('Error initializing notification service: $e',
          name: 'ReciterNotificationService', error: e);
    }
  }

  Future<void> showReciterNotification({
    required String reciterName,
    required String surahName,
    required bool isPlaying,
  }) async {
    try {
      developer.log('Showing reciter notification: $reciterName - $surahName',
          name: 'ReciterNotificationService');

      const androidDetails = AndroidNotificationDetails(
        'reciter_channel',
        'Reciter Notifications',
        channelDescription: 'Notifications for Quran recitations',
        importance: Importance.high,
        priority: Priority.high,
        ongoing: true,
        autoCancel: false,
        category: AndroidNotificationCategory.transport,
        showWhen: false,
        visibility: NotificationVisibility.public,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.active,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        1,
        reciterName,
        surahName,
        details,
        payload: isPlaying ? 'playing' : 'paused',
      );

      developer.log('Reciter notification shown successfully',
          name: 'ReciterNotificationService');
    } catch (e) {
      developer.log('Error showing reciter notification: $e',
          name: 'ReciterNotificationService', error: e);
    }
  }

  Future<void> removeNotification() async {
    try {
      developer.log('Removing notification',
          name: 'ReciterNotificationService');
      await _notifications.cancel(1);
      developer.log('Notification removed successfully',
          name: 'ReciterNotificationService');
    } catch (e) {
      developer.log('Error removing notification: $e',
          name: 'ReciterNotificationService', error: e);
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    developer.log('Notification tapped', name: 'ReciterNotificationService');
    onStop?.call();
  }
}
