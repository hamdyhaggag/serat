import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

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

  Future<void> initialize() async {
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
    );

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
  }

  Future<void> showRadioNotification({
    required String stationName,
    required bool isPlaying,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      ongoing: true,
      autoCancel: false,
      playSound: false,
      enableVibration: false,
      actions: [
        AndroidNotificationAction('play_pause', 'Play/Pause'),
        AndroidNotificationAction('stop', 'Stop'),
      ],
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: false,
      interruptionLevel: InterruptionLevel.active,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      1,
      'Radio Playback',
      isPlaying ? 'Now Playing: $stationName' : 'Paused: $stationName',
      details,
    );
  }

  Future<void> removeNotification() async {
    await _notifications.cancel(1);
  }

  void _onNotificationTap(NotificationResponse response) {
    switch (response.actionId) {
      case 'play_pause':
        onPlayPause?.call();
        break;
      case 'stop':
        onStop?.call();
        break;
      default:
        // Handle default tap
        break;
    }
  }
}
