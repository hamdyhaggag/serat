import 'package:flutter/material.dart';
import '../../imports.dart';

class NotificationService {
  static Future<void> initializeNotification() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelGroupKey: 'high_importance_channel_group',
          channelKey: 'high_importance_channel',
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel for basic tests',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          onlyAlertOnce: true,
          playSound: true,
          criticalAlerts: true,
        ),
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'high_importance_channel_group',
          channelGroupName: 'Group 1',
        ),
      ],
      debug: true,
    );

    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }

    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );
  }

  static Future<void> onNotificationCreatedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    debugPrint('onNotificationCreatedMethod');
  }

  static Future<void> onNotificationDisplayedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    debugPrint('onNotificationDisplayedMethod');
  }

  static Future<void> onDismissActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    debugPrint('onDismissActionReceivedMethod');
  }

  static Future<void> onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    debugPrint('onActionReceivedMethod');
    final payload = receivedAction.payload ?? {};
    if (payload["navigate"] == "true") {
      SeratApp.navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => const AzkarScreen()),
      );
    }
  }

  static Future<void> showNotification({
    required String title,
    String? body,
    String? summary,
    Map<String, String>? payload,
    NotificationLayout notificationLayout = NotificationLayout.Default,
    NotificationCategory? category,
    String? bigPicture,
    List<NotificationActionButton>? actionButtons,
    bool scheduled = false,
    TimeOfDay? selectedTimeMorning,
    required int interval,
    TimeOfDay? selectedTimeEvening,
  }) async {
    if (scheduled) {
      assert(
        selectedTimeMorning != null || selectedTimeEvening != null,
        "You must specify either selectedTimeMorning or selectedTimeEvening for scheduling.",
      );
    }

    final now = DateTime.now();
    DateTime? scheduledTime;

    if (scheduled && selectedTimeMorning != null) {
      scheduledTime = DateTime(
        now.year,
        now.month,
        now.day,
        selectedTimeMorning.hour,
        selectedTimeMorning.minute,
      );
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }
    } else if (scheduled && selectedTimeEvening != null) {
      scheduledTime = DateTime(
        now.year,
        now.month,
        now.day,
        selectedTimeEvening.hour,
        selectedTimeEvening.minute,
      );
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }
    }

    if (scheduledTime != null) {
      final delay = scheduledTime.difference(now);
      await Future.delayed(delay, () async {
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: -1,
            channelKey: 'high_importance_channel',
            title: title,
            body: body,
            notificationLayout: notificationLayout,
            summary: summary,
            category: category,
            payload: payload,
            bigPicture: bigPicture,
          ),
          actionButtons: actionButtons,
        );
      });
    } else {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: -1,
          channelKey: 'high_importance_channel',
          title: title,
          body: body,
          notificationLayout: notificationLayout,
          summary: summary,
          category: category,
          payload: payload,
          bigPicture: bigPicture,
        ),
        actionButtons: actionButtons,
      );
    }
  }
}
