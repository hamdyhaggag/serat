import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static const channelId = 'radio_playback_channel';
  static const channelName = 'Radio Playback';
  static const channelDescription = 'Control radio playback';

  // Callbacks for notification actions
  Function()? onPlayPause;
  Function()? onStop;

  // Static function for background notification handling
  @pragma('vm:entry-point')
  static void notificationTapBackground(NotificationResponse response) {
    developer.log(
      'Background notification tapped - ActionId: ${response.actionId}',
      name: 'NotificationService',
    );
  }

  Future<void> initialize() async {
    developer.log('Initializing notification service',
        name: 'NotificationService');

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    developer.log('Notification service initialized',
        name: 'NotificationService');

    // Create the notification channel for Android
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            channelId,
            channelName,
            description: channelDescription,
            importance: Importance.high,
            playSound: false,
            enableVibration: false,
          ),
        );

    developer.log('Android notification channel created',
        name: 'NotificationService');
  }

  Future<void> showRadioNotification({
    required String stationName,
    required bool isPlaying,
  }) async {
    developer.log(
      'Showing radio notification - Station: $stationName, IsPlaying: $isPlaying',
      name: 'NotificationService',
    );

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      ongoing: true,
      autoCancel: true,
      playSound: false,
      enableVibration: false,
      category: AndroidNotificationCategory.transport,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: false,
      interruptionLevel: InterruptionLevel.active,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      1,
      'الراديو',
      isPlaying ? 'جاري التشغيل: $stationName' : 'متوقف مؤقتاً: $stationName',
      details,
      payload: isPlaying ? 'playing' : 'paused',
    );

    developer.log('Radio notification shown successfully',
        name: 'NotificationService');
  }

  Future<void> removeNotification() async {
    developer.log('Removing notification', name: 'NotificationService');
    await _notifications.cancel(1);
    developer.log('Notification removed successfully',
        name: 'NotificationService');
  }

  void _onNotificationTap(NotificationResponse response) async {
    developer.log(
      'Notification action tapped - ActionId: ${response.actionId}, Payload: ${response.payload}',
      name: 'NotificationService',
    );

    // Handle notification tap (when user taps the notification body)
    if (response.actionId == null) {
      developer.log('Notification body tapped', name: 'NotificationService');
      if (onPlayPause != null) {
        onPlayPause!();
        developer.log('Play/Pause callback executed from body tap',
            name: 'NotificationService');
      }
      return;
    }

    switch (response.actionId) {
      case 'play_pause':
        developer.log('Play/Pause action triggered',
            name: 'NotificationService');
        if (onPlayPause != null) {
          onPlayPause!();
          developer.log('Play/Pause callback executed',
              name: 'NotificationService');
        } else {
          developer.log('Play/Pause callback is null',
              name: 'NotificationService');
        }
        break;
      case 'stop':
        developer.log('Stop action triggered', name: 'NotificationService');
        if (onStop != null) {
          onStop!();
          await removeNotification();
          developer.log('Stop callback executed and notification removed',
              name: 'NotificationService');
        } else {
          developer.log('Stop callback is null', name: 'NotificationService');
        }
        break;
      default:
        developer.log('Unknown action triggered: ${response.actionId}',
            name: 'NotificationService');
        break;
    }
  }
}
