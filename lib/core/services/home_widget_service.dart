import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import '../../Data/Model/times_model.dart';
import '../../Data/utils/cache_helper.dart';

class HomeWidgetService {
  static const String _androidWidgetName = 'PrayerWidgetProvider';

  static Future<void> updatePrayerWidget() async {
    final timesModel = await getTimeModel();
    if (timesModel == null) return;

    final now = DateTime.now();
    final timings = timesModel.data.timings;
    final hijri = timesModel.data.date.hijri;

    DateTime _parse(String time) {
      final parts = time.split(':');
      return DateTime(now.year, now.month, now.day, int.parse(parts[0]),
          int.parse(parts[1]));
    }

    final prayers = [
      {'name': 'الفجر', 'time': _parse(timings.fajr)},
      {'name': 'الشروق', 'time': _parse(timings.sunrise)},
      {'name': 'الظهر', 'time': _parse(timings.dhuhr)},
      {'name': 'العصر', 'time': _parse(timings.asr)},
      {'name': 'المغرب', 'time': _parse(timings.maghrib)},
      {'name': 'العشاء', 'time': _parse(timings.isha)},
    ];

    int nextIndex = -1;
    for (int i = 0; i < prayers.length; i++) {
      if ((prayers[i]['time'] as DateTime).isAfter(now)) {
        nextIndex = i;
        break;
      }
    }

    Map<String, dynamic> prev, next;
    bool isIqamahState = false;
    int iqamahMinutesLeft = 0;

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

    // Check if we are in the 15-minute Iqamah window after PREVIOUS prayer
    final diffFromPrev = now.difference(prev['time'] as DateTime);
    if (diffFromPrev.inMinutes >= 0 && diffFromPrev.inMinutes < 15) {
      isIqamahState = true;
      iqamahMinutesLeft = 15 - diffFromPrev.inMinutes;
    }

    final DateTime pTime = prev['time'];
    final DateTime nTime = next['time'];
    final totalDuration = nTime.difference(pTime).inSeconds;
    final elapsed = now.difference(pTime).inSeconds;
    final progress = (elapsed / totalDuration * 100).clamp(0, 100).toInt();

    final remaining = nTime.difference(now);

    String progressColor;
    String remH, remM;

    if (isIqamahState) {
      progressColor = "#FFD700"; // Gold/Yellow for Iqamah
      remH = "0";
      remM = iqamahMinutesLeft.toString().padLeft(2, '0');
      await HomeWidget.saveWidgetData(
          'iqamah_label', "للإقامة"); // Optional label
    } else if (remaining.inMinutes < 15) {
      progressColor = "#FF4444"; // Red for Urgent
      remH = remaining.inHours.toString();
      remM = remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
      await HomeWidget.saveWidgetData('iqamah_label', "للصلاة");
    } else {
      progressColor = "#00FFCC"; // Turquoise for Normal
      remH = remaining.inHours.toString();
      remM = remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
      await HomeWidget.saveWidgetData('iqamah_label', "للصلاة");
    }

    // Save Data
    await HomeWidget.saveWidgetData(
        'current_time', DateFormat('hh:mm').format(now));
    await HomeWidget.saveWidgetData('hijri_date',
        '${hijri.weekday.ar} ${hijri.day} ${hijri.month.ar} ${hijri.year}');
    await HomeWidget.saveWidgetData('progress', progress);
    await HomeWidget.saveWidgetData('progress_color', progressColor);

    await HomeWidget.saveWidgetData('prev_name', prev['name']);
    await HomeWidget.saveWidgetData(
        'prev_time', DateFormat('hh:mm').format(pTime));
    await HomeWidget.saveWidgetData('next_name', next['name']);
    await HomeWidget.saveWidgetData(
        'next_time', DateFormat('hh:mm').format(nTime));

    await HomeWidget.saveWidgetData('rem_h', remH);
    await HomeWidget.saveWidgetData('rem_m', remM);

    await HomeWidget.updateWidget(
      name: _androidWidgetName,
      androidName: _androidWidgetName,
    );
  }
}
