import 'package:flutter/material.dart';
import 'package:serat/shared/services/notification_service.dart';
import 'package:serat/shared/styles/app_colors.dart';
import 'package:serat/shared/widgets/app_text.dart';
import 'package:intl/intl.dart';
import 'package:serat/shared/network/local/cache_helper.dart';
import 'dart:convert';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<NotificationItem> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeCache();
  }

  Future<void> _initializeCache() async {
    await CacheHelper.init();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final cachedNotifications = CacheHelper.getString(key: 'notifications');
      if (cachedNotifications.isNotEmpty) {
        final List<dynamic> decodedNotifications =
            json.decode(cachedNotifications);
        setState(() {
          _notifications.clear();
          _notifications.addAll(
            decodedNotifications
                .map((item) => NotificationItem.fromJson(item))
                .toList(),
          );
        });
      } else {
        // Add sample notifications if no cached data exists
        setState(() {
          _notifications.clear();
          _notifications.addAll([
            NotificationItem(
              id: 1,
              title: 'حان وقت صلاة الفجر',
              body: 'حان وقت صلاة الفجر - 04:30 صباحاً',
              timestamp: DateTime.now().subtract(const Duration(hours: 2)),
              type: NotificationType.prayer,
            ),
            NotificationItem(
              id: 2,
              title: 'إشعار تجريبي',
              body: 'هذا إشعار تجريبي للتجربة',
              timestamp: DateTime.now().subtract(const Duration(hours: 1)),
              type: NotificationType.test,
            ),
            NotificationItem(
              id: 3,
              title: 'حان وقت صلاة الظهر',
              body: 'حان وقت صلاة الظهر - 12:30 ظهراً',
              timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
              type: NotificationType.prayer,
            ),
          ]);
        });
        // Cache the sample notifications
        _cacheNotifications();
      }
    } catch (e) {
      print('Error loading notifications: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cacheNotifications() async {
    try {
      final notificationsJson =
          _notifications.map((notification) => notification.toJson()).toList();
      await CacheHelper.saveData(
        key: 'notifications',
        value: json.encode(notificationsJson),
      );
    } catch (e) {
      print('Error caching notifications: $e');
    }
  }

  Future<void> _clearNotification(int id) async {
    setState(() {
      _notifications.removeWhere((notification) => notification.id == id);
    });
    await _cacheNotifications();
  }

  Future<void> _clearAllNotifications() async {
    setState(() {
      _notifications.clear();
    });
    await CacheHelper.removeData(key: 'notifications');
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xff1F1F1F) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode
            ? const Color(0xff2F2F2F)
            : Theme.of(context).primaryColor,
        title: const AppText(
          'الإشعارات',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.white),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor:
                        isDarkMode ? const Color(0xff2F2F2F) : Colors.white,
                    title: const AppText(
                      'مسح جميع الإشعارات',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    content: const AppText(
                      'هل أنت متأكد من رغبتك في مسح جميع الإشعارات؟',
                      fontSize: 16,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const AppText(
                          'إلغاء',
                          color: Colors.grey,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _clearAllNotifications();
                        },
                        child: AppText(
                          'مسح',
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color:
                    isDarkMode ? Colors.white : Theme.of(context).primaryColor,
              ),
            )
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_off_outlined,
                        size: 64,
                        color: isDarkMode
                            ? Colors.grey[600]
                            : Theme.of(context).primaryColor.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      AppText(
                        'لا توجد إشعارات',
                        fontSize: 18,
                        color: isDarkMode
                            ? Colors.grey[400]!
                            : Theme.of(context).primaryColor.withOpacity(0.7),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    return _buildNotificationCard(notification, isDarkMode);
                  },
                ),
    );
  }

  Widget _buildNotificationCard(
      NotificationItem notification, bool isDarkMode) {
    return Dismissible(
      key: Key(notification.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
        ),
      ),
      onDismissed: (direction) => _clearNotification(notification.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xff2F2F2F) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // TODO: Handle notification tap
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .primaryColor
                          .withOpacity(isDarkMode ? 0.2 : 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getNotificationIcon(notification.type),
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          notification.title,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode
                              ? Colors.white
                              : Theme.of(context).primaryColor,
                        ),
                        const SizedBox(height: 4),
                        AppText(
                          notification.body,
                          fontSize: 14,
                          color: isDarkMode
                              ? Colors.grey[300]!
                              : Colors.grey[600]!,
                        ),
                        const SizedBox(height: 8),
                        AppText(
                          _formatTimestamp(notification.timestamp),
                          fontSize: 12,
                          color: isDarkMode
                              ? Colors.grey[400]!
                              : Colors.grey[500]!,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return DateFormat('dd/MM/yyyy').format(timestamp);
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.prayer:
        return Icons.mosque;
      case NotificationType.test:
        return Icons.notifications;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.prayer:
        return AppColors.primaryColor;
      case NotificationType.test:
        return AppColors.primaryColor;
      default:
        return AppColors.primaryColor;
    }
  }
}

enum NotificationType {
  prayer,
  test,
}

class NotificationItem {
  final int id;
  final String title;
  final String body;
  final DateTime timestamp;
  final NotificationType type;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString(),
    };
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      timestamp: DateTime.parse(json['timestamp']),
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => NotificationType.test,
      ),
    );
  }
}
