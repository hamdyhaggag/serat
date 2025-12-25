import 'dart:developer';
import 'dart:ui';
import 'dart:isolate';
import 'dart:convert';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Data/Model/times_model.dart';

class AdhanService {
  static const int adhanAlarmId = 1000;
  static const int preAdhanAlarmId = 2000;
  static const String adhanChannelId = "adhan_notifications";
  static const String isolateName = "adhan_bg_port";

  static final AudioPlayer _player = AudioPlayer();
  static AudioPlayer get player => _player;

  static ReceivePort? _receivePort;

  @pragma('vm:entry-point')
  static void onNotificationAction(NotificationResponse response) async {
    log("Notification Action: ${response.actionId}");
    if (response.actionId == 'stop_adhan' || response.payload == 'adhan_stop') {
      sendStopSignal();
    }
  }

  static void sendStopSignal() {
    log("Sending global STOP signal...");
    IsolateNameServer.lookupPortByName(isolateName)?.send("stop_now");
    IsolateNameServer.lookupPortByName('adhan_ui_port')?.send("stop_now");
    stopAdhanLocally();
  }

  static void initializeIsolateListener() {
    log("Initializing Adhan Port: $isolateName");
    _receivePort?.close();
    _receivePort = ReceivePort();
    IsolateNameServer.removePortNameMapping(isolateName);
    IsolateNameServer.registerPortWithName(_receivePort!.sendPort, isolateName);

    _receivePort!.listen((message) {
      if (message == "stop_now") {
        log("Background isolate received stop signal");
        stopAdhanLocally();
      }
    });
  }

  @pragma('vm:entry-point')
  static void playAdhanCallback() async {
    initializeIsolateListener();
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('isAdhanEnabled') ?? true)) return;

    final timesJson = prefs.getString('TimesModel');
    if (timesJson == null) return;

    final timesModel = TimesModel.fromJson(jsonDecode(timesJson));
    final timings = timesModel.data.timings;
    final now = DateTime.now();

    String prayerName = "";
    String fileName = "adhan -mishary rashid.mp3";

    if (_isTimeNear(now, timings.fajr)) {
      prayerName = "الفجر";
      fileName = "adhan fajr -mishary rashid.mp3";
    } else if (_isTimeNear(now, timings.dhuhr)) {
      prayerName = "الظهر";
    } else if (_isTimeNear(now, timings.asr)) {
      prayerName = "العصر";
    } else if (_isTimeNear(now, timings.maghrib)) {
      prayerName = "المغرب";
    } else if (_isTimeNear(now, timings.isha)) {
      prayerName = "العشاء";
    }

    if (prayerName.isEmpty) return;

    final Map<String, String> keyMap = {
      "الفجر": "Fajr",
      "الظهر": "Dhuhr",
      "العصر": "Asr",
      "المغرب": "Maghrib",
      "العشاء": "Isha"
    };
    if (!(prefs.getBool('adhan_${keyMap[prayerName]}') ?? true)) return;

    await _showAdhanNotification(prayerName);

    try {
      await _player.play(AssetSource("adhan/$fileName"));
    } catch (e) {
      log("Play error: $e");
    }
  }

  @pragma('vm:entry-point')
  static void playPreAdhanCallback() async {
    initializeIsolateListener();
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('isPreAdhanEnabled') ?? false)) return;

    final timesJson = prefs.getString('TimesModel');
    if (timesJson == null) return;

    final timesModel = TimesModel.fromJson(jsonDecode(timesJson));
    final timings = timesModel.data.timings;
    final now = DateTime.now();
    final leadMinutes = prefs.getInt('preAdhanMinutes') ?? 15;

    String prayerName = "";
    String fileName = "";

    if (_isTimeNear(now.add(Duration(minutes: leadMinutes)), timings.fajr)) {
      prayerName = "الفجر";
      fileName = "pre_fajr.mp3";
    } else if (_isTimeNear(
        now.add(Duration(minutes: leadMinutes)), timings.dhuhr)) {
      if (now.weekday == DateTime.friday) {
        prayerName = "الجمعة";
        fileName = "pre_jumuah.mp3";
      } else {
        prayerName = "الظهر";
        fileName = "pre_dhuhr.mp3";
      }
    } else if (_isTimeNear(
        now.add(Duration(minutes: leadMinutes)), timings.asr)) {
      prayerName = "العصر";
      fileName = "pre_asr.mp3";
    } else if (_isTimeNear(
        now.add(Duration(minutes: leadMinutes)), timings.maghrib)) {
      prayerName = "المغرب";
      fileName = "pre_maghrib.mp3";
    } else if (_isTimeNear(
        now.add(Duration(minutes: leadMinutes)), timings.isha)) {
      prayerName = "العشاء";
      fileName = "pre_isha.mp3";
    }

    if (prayerName.isEmpty || fileName.isEmpty) return;

    await _showPreAdhanNotification(prayerName, leadMinutes);

    try {
      await _player.play(AssetSource("adhan/$fileName"));
    } catch (e) {
      log("Pre-Adhan Play error: $e");
    }
  }

  static bool _isTimeNear(DateTime now, String timeStr) {
    final parts = timeStr.split(':');
    final pTime = DateTime(
        now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
    return now.difference(pTime).inMinutes.abs() <= 2;
  }

  static Future<void> _showAdhanNotification(String prayerName) async {
    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.initialize(
      const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher')),
      onDidReceiveNotificationResponse: (res) => onNotificationAction(res),
      onDidReceiveBackgroundNotificationResponse: onNotificationAction,
    );

    const android = AndroidNotificationDetails(
      adhanChannelId,
      'الأذان',
      channelDescription: 'تنبيهات صوت الأذان',
      importance: Importance.max,
      priority: Priority.max,
      fullScreenIntent: true,
      ongoing: true,
      autoCancel: false,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction('stop_adhan', 'إيقاف الأذان',
            showsUserInterface: false),
      ],
    );

    await plugin.show(
        999,
        'حان وقت الأذان',
        'صلاة $prayerName بصوت مشاري العفاسي',
        const NotificationDetails(android: android),
        payload: 'adhan_stop');
  }

  static Future<void> _showPreAdhanNotification(
      String prayerName, int minutes) async {
    final plugin = FlutterLocalNotificationsPlugin();
    const android = AndroidNotificationDetails(
      'pre_adhan_reminder',
      'تنبيه اقتراب الصلاة',
      channelDescription: 'تنبيه صوتي قبل موعد الصلاة',
      importance: Importance.high,
      priority: Priority.high,
      autoCancel: true,
    );

    await plugin.show(
        888,
        'اقتربت صلاة $prayerName',
        'باقي $minutes دقيقة على موعد الأذان',
        const NotificationDetails(android: android));
  }

  static Future<void> testFullExperience() async {
    initializeIsolateListener();
    await _showAdhanNotification("تجريبية");
    try {
      await _player.play(AssetSource("adhan/adhan -mishary rashid.mp3"));
    } catch (e) {
      log("Test play error: $e");
    }
  }

  static Future<void> testPreAdhanExperience() async {
    initializeIsolateListener();
    await _showPreAdhanNotification("الفجر", 15);
    try {
      await _player.play(AssetSource("adhan/pre_fajr.mp3"));
    } catch (e) {
      log("Test pre-play error: $e");
    }
  }

  static Future<void> stopAdhanLocally() async {
    log("Executing local stop...");
    try {
      await _player.stop();
    } catch (e) {
      log("Stop error: $e");
    }
    await FlutterLocalNotificationsPlugin().cancel(999);
  }

  static Future<void> scheduleAdhans([TimesModel? timesModel]) async {
    final prefs = await SharedPreferences.getInstance();

    if (timesModel == null) {
      final timesJson = prefs.getString('TimesModel');
      if (timesJson != null) {
        timesModel = TimesModel.fromJson(jsonDecode(timesJson));
      }
    }

    if (timesModel == null) return;

    final timings = timesModel.data.timings;
    final now = DateTime.now();

    final isEnabled = prefs.getBool('isAdhanEnabled') ?? true;
    final isPreEnabled = prefs.getBool('isPreAdhanEnabled') ?? false;
    final preMinutes = prefs.getInt('preAdhanMinutes') ?? 15;

    DateTime parse(String t) {
      final p = t.split(':');
      return DateTime(
          now.year, now.month, now.day, int.parse(p[0]), int.parse(p[1]));
    }

    final Map<String, DateTime> prayers = {
      'Fajr': parse(timings.fajr),
      'Dhuhr': parse(timings.dhuhr),
      'Asr': parse(timings.asr),
      'Maghrib': parse(timings.maghrib),
      'Isha': parse(timings.isha),
    };

    for (var entry in prayers.entries) {
      // 1. Schedule main Adhan
      if (isEnabled && entry.value.isAfter(now)) {
        await AndroidAlarmManager.oneShotAt(
          entry.value,
          adhanAlarmId + _getPrayerId(entry.key),
          playAdhanCallback,
          exact: true,
          wakeup: true,
          rescheduleOnReboot: true,
        );
      }

      // 2. Schedule Pre-Adhan Reminder
      if (isPreEnabled) {
        final reminderTime =
            entry.value.subtract(Duration(minutes: preMinutes));
        if (reminderTime.isAfter(now)) {
          await AndroidAlarmManager.oneShotAt(
            reminderTime,
            preAdhanAlarmId + _getPrayerId(entry.key),
            playPreAdhanCallback,
            exact: true,
            wakeup: true,
            rescheduleOnReboot: true,
          );
          log("Scheduled Pre-Adhan for ${entry.key} at $reminderTime");
        }
      }
    }
  }

  static int _getPrayerId(String name) {
    switch (name) {
      case 'Fajr':
        return 1;
      case 'Dhuhr':
        return 2;
      case 'Asr':
        return 3;
      case 'Maghrib':
        return 4;
      case 'Isha':
        return 5;
      default:
        return 0;
    }
  }
}
