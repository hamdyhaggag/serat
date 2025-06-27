import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:serat/shared/services/notification_service.dart';

class FirebaseMessagingService {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _notificationService = NotificationService();

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    log("FCM Token: $fCMToken");
    // Initialization is already handled in main.dart
    // _notificationService.initialize();
    initPushNotifications();
  }

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;

    // TODO: Navigate to a specific screen
    log('Message received: ${message.notification?.title}');
  }

  Future<void> initPushNotifications() async {
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);

    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);

    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;

      _notificationService.showGeneralNotification(
        title: notification.title ?? '',
        body: notification.body ?? '',
      );
    });
  }
}
