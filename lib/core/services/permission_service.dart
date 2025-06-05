import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class PermissionService {
  static Future<bool> requestLocationPermission(BuildContext context) async {
    final status = await Permission.location.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await _showPermissionDialog(
        context,
        'Location Permission',
        'Serat needs location access to provide accurate prayer times and Qibla direction for your current location. This information is processed locally and is not stored on our servers.',
      );

      if (result) {
        final newStatus = await Permission.location.request();
        return newStatus.isGranted;
      }
    }

    if (status.isPermanentlyDenied) {
      await _showSettingsDialog(
        context,
        'Location Permission Required',
        'Please enable location access in your device settings to use prayer times and Qibla features.',
      );
    }

    return false;
  }

  static Future<bool> requestNotificationPermission(
      BuildContext context) async {
    final status = await Permission.notification.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await _showPermissionDialog(
        context,
        'Notification Permission',
        'Serat needs notification permission to send you prayer time alerts and important Islamic reminders. You can customize these notifications in the app settings.',
      );

      if (result) {
        final newStatus = await Permission.notification.request();
        return newStatus.isGranted;
      }
    }

    return false;
  }

  static Future<bool> requestAudioPermission(BuildContext context) async {
    final status = await Permission.audio.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await _showPermissionDialog(
        context,
        'Audio Permission',
        'Serat needs audio permission to play Quran recitations and Azkar audio. This permission is only used when you choose to play audio content.',
      );

      if (result) {
        final newStatus = await Permission.audio.request();
        return newStatus.isGranted;
      }
    }

    return false;
  }

  static Future<bool> _showPermissionDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    bool? result;
    await AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.bottomSlide,
      title: title,
      desc: message,
      btnOkText: 'Allow',
      btnCancelText: 'Deny',
      btnOkOnPress: () => result = true,
      btnCancelOnPress: () => result = false,
    ).show();

    return result ?? false;
  }

  static Future<void> _showSettingsDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    await AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.bottomSlide,
      title: title,
      desc: message,
      btnOkText: 'Open Settings',
      btnCancelText: 'Not Now',
      btnOkOnPress: () => openAppSettings(),
      btnCancelOnPress: () {},
    ).show();
  }

  static Future<bool> checkAndRequestBatteryOptimization(
      BuildContext context) async {
    if (await Permission.ignoreBatteryOptimizations.isGranted) {
      return true;
    }

    final result = await _showPermissionDialog(
      context,
      'Battery Optimization',
      'To ensure prayer time notifications work reliably, Serat needs to be excluded from battery optimization. This helps maintain accurate prayer time alerts.',
    );

    if (result) {
      final status = await Permission.ignoreBatteryOptimizations.request();
      return status.isGranted;
    }

    return false;
  }
}
