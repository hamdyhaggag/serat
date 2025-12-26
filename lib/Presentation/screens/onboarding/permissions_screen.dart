import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:serat/imports.dart';
import '../screen_layout.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  bool _notificationsGranted = false;
  bool _locationGranted = false;
  bool _exactAlarmGranted = false;
  bool _batteryOptimizationGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final notificationStatus = await Permission.notification.status;
    final locationStatus = await Permission.locationWhenInUse.status;

    // Exact alarms permission (Android 12+)
    final alarmStatus = await Permission.scheduleExactAlarm.status;

    // Battery optimization
    final batteryStatus = await Permission.ignoreBatteryOptimizations.status;

    setState(() {
      _notificationsGranted = notificationStatus.isGranted;
      _locationGranted = locationStatus.isGranted;
      _exactAlarmGranted = alarmStatus.isGranted;
      _batteryOptimizationGranted = batteryStatus.isGranted;
    });
  }

  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.request();
    setState(() => _notificationsGranted = status.isGranted);
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      // Also request always for background updates if needed,
      // but let's stick to base for now to keep it simple
      setState(() => _locationGranted = true);
    }
  }

  Future<void> _requestAlarmPermission() async {
    final status = await Permission.scheduleExactAlarm.request();
    setState(() => _exactAlarmGranted = status.isGranted);
  }

  Future<void> _requestBatteryPermission() async {
    final status = await Permission.ignoreBatteryOptimizations.request();
    setState(() => _batteryOptimizationGranted = status.isGranted);
  }

  bool get _allRequiredGranted =>
      _notificationsGranted && _locationGranted && _exactAlarmGranted;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [const Color(0xFF121212), const Color(0xFF1E1E1E)]
                : [const Color(0xFFF8F9FA), const Color(0xFFE9ECEF)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                Text(
                  "لنكمل إعداد تجربتك",
                  style: TextStyle(
                    fontFamily: "Cairo",
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : AppColors.primaryColor,
                  ),
                ).animate().fade().slideX(begin: -0.2, end: 0),
                const SizedBox(height: 12),
                Text(
                  "يحتاج صراط إلى بعض الأذونات ليعمل بشكل صحيح ويصلك الأذان في وقته بدقة.",
                  style: TextStyle(
                    fontFamily: "Cairo",
                    fontSize: 16,
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                ).animate().fade(delay: 200.ms).slideX(begin: -0.2, end: 0),
                const SizedBox(height: 40),

                // Permission Items
                _buildPermissionItem(
                  icon: Icons.notifications_active_rounded,
                  title: "التنبيهات",
                  desc: "لإرسال إشعارات الأذان والذكر في وقتها.",
                  isGranted: _notificationsGranted,
                  onTap: _requestNotificationPermission,
                ).animate().fade(delay: 400.ms).slideY(begin: 0.2, end: 0),

                _buildPermissionItem(
                  icon: Icons.location_on_rounded,
                  title: "الموقع الجغرافي",
                  desc: "لحساب مواقيت الصلاة بدقة بناءً على مكانك.",
                  isGranted: _locationGranted,
                  onTap: _requestLocationPermission,
                ).animate().fade(delay: 500.ms).slideY(begin: 0.2, end: 0),

                _buildPermissionItem(
                  icon: Icons.alarm_rounded,
                  title: "المنبهات الدقيقة",
                  desc: "لضمان انطلاق الأذان في اللحظة الصحيحة تماماً.",
                  isGranted: _exactAlarmGranted,
                  onTap: _requestAlarmPermission,
                ).animate().fade(delay: 600.ms).slideY(begin: 0.2, end: 0),

                _buildPermissionItem(
                  icon: Icons.battery_saver_rounded,
                  title: "تجاهل تحسين البطارية",
                  desc: "لمنع النظام من إيقاف التطبيق في الخلفية.",
                  isGranted: _batteryOptimizationGranted,
                  onTap: _requestBatteryPermission,
                ).animate().fade(delay: 700.ms).slideY(begin: 0.2, end: 0),

                const Spacer(flex: 2),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_allRequiredGranted) {
                        navigateTo(context, const ScreenLayout());
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "يرجى منح أذونات الموقع والتنبيهات للمتابعة",
                              textAlign: TextAlign.right,
                              style: TextStyle(fontFamily: "Cairo"),
                            ),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _allRequiredGranted
                          ? AppColors.primaryColor
                          : Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "بدء التطبيق",
                      style: TextStyle(
                        fontFamily: "Cairo",
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ).animate().fade(delay: 900.ms).scale(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionItem({
    required IconData icon,
    required String title,
    required String desc,
    required bool isGranted,
    required VoidCallback onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: isGranted ? null : onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isGranted
                ? AppColors.primaryColor.withOpacity(0.5)
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            if (!isDarkMode)
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isGranted
                    ? AppColors.primaryColor.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isGranted ? AppColors.primaryColor : Colors.grey,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: "Cairo",
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    desc,
                    style: TextStyle(
                      fontFamily: "Cairo",
                      fontSize: 12,
                      color: isDarkMode ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            if (isGranted)
              Icon(Icons.check_circle_rounded, color: AppColors.primaryColor)
            else
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: isDarkMode ? Colors.white24 : Colors.black26),
          ],
        ),
      ),
    );
  }
}
