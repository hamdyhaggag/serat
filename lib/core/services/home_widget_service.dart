import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/widgets.dart';
import '../../Data/Model/times_model.dart';
import '../../Data/utils/cache_helper.dart';

@pragma('vm:entry-point')
void widgetUpdateCallback() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CacheHelper.init();
  await HomeWidgetService.updatePrayerWidget();
}

class HomeWidgetService {
  static const String _androidWidgetName = 'PrayerWidgetProvider';
  static const String _androidListWidgetName = 'ListPrayerWidgetProvider';
  static const int _widgetAlarmId = 888;

  static Future<void> updatePrayerWidget() async {
    final timesModel = await getTimeModel();
    if (timesModel == null) return;

    final now = DateTime.now();
    final timings = timesModel.data.timings;
    final hijri = timesModel.data.date.hijri;

    DateTime _parse(String time) {
      final now = DateTime.now();
      if (time.isEmpty) return now;
      try {
        // Remove suffix like (EET)
        final cleanTime = time.split(' ')[0];
        final parts = cleanTime.split(':');
        if (parts.length < 2) return now;
        return DateTime(now.year, now.month, now.day,
            int.parse(parts[0].trim()), int.parse(parts[1].trim()));
      } catch (e) {
        return now;
      }
    }

    final prayers = [
      {'key': 'fajr', 'name': 'الفجر', 'time': _parse(timings.fajr)},
      {'key': 'sunrise', 'name': 'الشروق', 'time': _parse(timings.sunrise)},
      {'key': 'dhuhr', 'name': 'الظهر', 'time': _parse(timings.dhuhr)},
      {'key': 'asr', 'name': 'العصر', 'time': _parse(timings.asr)},
      {'key': 'maghrib', 'name': 'المغرب', 'time': _parse(timings.maghrib)},
      {'key': 'isha', 'name': 'العشاء', 'time': _parse(timings.isha)},
    ];

    int nextIndex = -1;
    for (int i = 0; i < prayers.length; i++) {
      if ((prayers[i]['time'] as DateTime).isAfter(now)) {
        nextIndex = i;
        break;
      }
    }

    // For the list widget highlighting (if all prayers today passed, next is Fajr tomorrow)
    int highlightedIndex = nextIndex;
    if (highlightedIndex == -1) highlightedIndex = 0;

    Map<String, dynamic> prev, next;
    double progress = 0;

    if (nextIndex == -1) {
      prev = prayers.last;
      next = {
        'name': 'الفجر',
        'time': (prayers.first['time'] as DateTime).add(const Duration(days: 1))
      };
    } else if (nextIndex == 0) {
      prev = {
        'name': 'العشاء',
        'time':
            (prayers.last['time'] as DateTime).subtract(const Duration(days: 1))
      };
      next = prayers.first;
    } else {
      prev = prayers[nextIndex - 1];
      next = prayers[nextIndex];
    }

    final DateTime pTime = prev['time'];
    final DateTime nTime = next['time'];
    final remaining = nTime.difference(now);

    // Dynamic Color and Progress Logic
    String progressColor;
    String remH, remM;
    String label = "للصلاة";

    // 1. Check for Iqamah (First 15 mins after prayer)
    final diffFromPrev = now.difference(pTime);
    if (diffFromPrev.inMinutes >= 0 && diffFromPrev.inMinutes < 15) {
      progressColor = "#FFD700"; // Gold
      progress =
          (diffFromPrev.inSeconds / (15 * 60)) * 100; // Progress of the 15 mins
      remH = "0";
      remM = (15 - diffFromPrev.inMinutes).toString().padLeft(2, '0');
      label = "للإقامة";
    }
    // 2. Check for Standby (Last 15 mins before next prayer)
    else if (remaining.inMinutes < 15) {
      progressColor = "#FF4444"; // Red
      final totalInterval = nTime.difference(pTime).inSeconds;
      final elapsed = now.difference(pTime).inSeconds;
      progress = (elapsed / totalInterval) * 100;
      remH = remaining.inHours.toString();
      remM = remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    }
    // 3. Normal State
    else {
      progressColor = "#00FFCC"; // Turquoise
      final totalInterval = nTime.difference(pTime).inSeconds;
      final elapsed = now.difference(pTime).inSeconds;
      progress = (elapsed / totalInterval) * 100;
      remH = remaining.inHours.toString();
      remM = remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    }

    // --- Save Data for Classic Widget ---
    await HomeWidget.saveWidgetData('hijri_date',
        '${hijri.weekday.ar} ${hijri.day} ${hijri.month.ar} ${hijri.year}');
    await HomeWidget.saveWidgetData('progress', progress.clamp(0, 100).toInt());
    await HomeWidget.saveWidgetData('progress_color', progressColor);
    await HomeWidget.saveWidgetData('iqamah_label', label);
    await HomeWidget.saveWidgetData('prev_name', prev['name']);
    await HomeWidget.saveWidgetData(
        'prev_time', DateFormat('hh:mm').format(pTime));
    await HomeWidget.saveWidgetData('next_name', next['name']);
    await HomeWidget.saveWidgetData(
        'next_time', DateFormat('hh:mm').format(nTime));
    await HomeWidget.saveWidgetData('rem_h', remH);
    await HomeWidget.saveWidgetData('rem_m', remM);

    // --- Save Data for List Widget ---
    await HomeWidget.saveWidgetData('next_index', highlightedIndex);
    for (final p in prayers) {
      final pDate = p['time'] as DateTime;
      await HomeWidget.saveWidgetData(
          '${p['key']}_time', DateFormat('hh:mm').format(pDate));
      await HomeWidget.saveWidgetData(
          '${p['key']}_ampm', DateFormat('a').format(pDate));
    }

    // Update both widgets
    await HomeWidget.updateWidget(
      name: _androidWidgetName,
      androidName: _androidWidgetName,
    );
    await HomeWidget.updateWidget(
      name: _androidListWidgetName,
      androidName: _androidListWidgetName,
    );

    // Schedule next update at the beginning of the next minute to keep countdown "alive"
    final nextMinute =
        DateTime(now.year, now.month, now.day, now.hour, now.minute + 1);
    await AndroidAlarmManager.oneShotAt(
      nextMinute,
      _widgetAlarmId,
      widgetUpdateCallback,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );
  }
}
