import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'notification_button.dart';
import 'notification_service.dart';

class NotificationUtilitis extends StatelessWidget {
  const NotificationUtilitis({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Colors.grey[200]!,
          ],
        )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            NotificationButton(
              text: "Normal Notification",
              onPressed: () async {
                await NotificationService.showNotification(
                  title: "Title of the notification",
                  body: "Body of the notification",
                  interval: 0,
                );
              },
            ),
            NotificationButton(
              text: "Notification With Summary",
              onPressed: () async {
                await NotificationService.showNotification(
                  title: "Title of the notification",
                  body: "Body of the notification",
                  summary: "Small Summary",
                  notificationLayout: NotificationLayout.Inbox,
                  interval: 0,
                );
              },
            ),
            NotificationButton(
              text: "Progress Bar Notification",
              onPressed: () async {
                await NotificationService.showNotification(
                  title: "Title of the notification",
                  body: "Body of the notification",
                  summary: "Small Summary",
                  notificationLayout: NotificationLayout.ProgressBar,
                  interval: 0,
                );
              },
            ),
            NotificationButton(
              text: "Message Notification",
              onPressed: () async {
                await NotificationService.showNotification(
                  title: "Title of the notification",
                  body: "Body of the notification",
                  summary: "Small Summary",
                  notificationLayout: NotificationLayout.Messaging,
                  interval: 0,
                );
              },
            ),
            NotificationButton(
              text: "Big Image Notification",
              onPressed: () async {
                await NotificationService.showNotification(
                  title: "Title of the notification",
                  body: "Body of the notification",
                  summary: "Small Summary",
                  notificationLayout: NotificationLayout.BigPicture,
                  bigPicture:
                      "https://files.tecnoblog.net/wp-content/uploads/2019/09/emoji.jpg",
                  interval: 0,
                );
              },
            ),
            NotificationButton(
              text: "Action Buttons Notification",
              onPressed: () async {
                await NotificationService.showNotification(
                    title: "Title of the notification",
                    body: "Body of the notification",
                    payload: {
                      "navigate": "true",
                    },
                    actionButtons: [
                      NotificationActionButton(
                        key: 'check',
                        label: 'Check it out',
                        color: Colors.green,
                      )
                    ],
                    interval: 0);
              },
            ),
            NotificationButton(
              text: "Scheduled Notification",
              onPressed: () async {
                await NotificationService.showNotification(
                  title: "Scheduled Notification",
                  body: "Notification was fired after 5 seconds",
                  scheduled: true,
                  interval: 5,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
