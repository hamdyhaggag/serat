import 'dart:developer';
import 'dart:ui';
import 'dart:isolate';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:audio_session/audio_session.dart' as as_session;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Data/Model/times_model.dart';
import '../../Data/Model/calendar_model.dart';
import 'home_widget_service.dart';

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
    final start = DateTime.now();
    log("AdhanService: playAdhanCallback started at $start");
    WidgetsFlutterBinding.ensureInitialized();
    initializeIsolateListener();
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('isAdhanEnabled') ?? true)) return;

    final now = DateTime.now();
    Timings? timings;

    // 1. Try to load from CalendarModel (Most Accurate)
    final calendarJson = prefs.getString('CalendarModel');
    if (calendarJson != null) {
      try {
        final calendarModel = CalendarModel.fromJson(jsonDecode(calendarJson));
        final todayStr =
            "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}";
        final dayData = calendarModel.data.firstWhere(
          (element) => element.date.gregorian.date == todayStr,
        );
        timings = dayData.timings;
      } catch (e) {
        log("Error loading calendar in callback: $e");
      }
    }

    // 2. Fallback to TimesModel (Backup)
    if (timings == null) {
      final timesJson = prefs.getString('TimesModel');
      if (timesJson != null) {
        final timesModel = TimesModel.fromJson(jsonDecode(timesJson));
        timings = timesModel.data.timings;
      }
    }

    if (timings == null) return;

    // ---------------------------------------------------------
    // ROBUST PRAYER DETECTION LOGIC
    // ---------------------------------------------------------
    String prayerName = "";
    String fileName = "adhan -mishary rashid.mp3";
    int minDiffMinutes = 9999;

    var prayers = {
      "الفجر": timings.fajr,
      "الظهر": timings.dhuhr,
      "العصر": timings.asr,
      "المغرب": timings.maghrib,
      "العشاء": timings.isha,
    };

    // Helper to parse today's time
    DateTime? parseTodayTime(String t) {
      try {
        final clean = t.split(' ')[0].trim();
        final parts = clean.split(':');
        return DateTime(now.year, now.month, now.day, int.parse(parts[0]),
            int.parse(parts[1]));
      } catch (_) {
        return null;
      }
    }

    prayers.forEach((pName, pTimeStr) {
      final pDate = parseTodayTime(pTimeStr);
      if (pDate != null) {
        final diff = now.difference(pDate).inMinutes.abs();
        // Tight window: 5 minutes to avoid matching wrong prayer
        if (diff < 5 && diff < minDiffMinutes) {
          minDiffMinutes = diff;
          prayerName = pName;
        }
      }
    });

    // Handle midnight edge case (E.g. Isha was at 23:50 yesterday, now is 00:10)
    if (prayerName.isEmpty && now.hour < 1) {
      prayerName = "العشاء";
      log("AdhanService: Late night detected, assuming Isha due to system delay");
    }

    log("AdhanService: Detected Prayer: $prayerName (Diff: $minDiffMinutes min)");

    if (prayerName == "الفجر") {
      fileName = "adhan fajr -mishary rashid.mp3";
    }
    // ---------------------------------------------------------

    if (prayerName.isEmpty) return;

    final Map<String, String> keyMap = {
      "الفجر": "Fajr",
      "الظهر": "Dhuhr",
      "العصر": "Asr",
      "المغرب": "Maghrib",
      "العشاء": "Isha"
    };
    if (!(prefs.getBool('adhan_${keyMap[prayerName]}') ?? true)) return;

    // Configure AudioSession for Alarm usage
    final session = await as_session.AudioSession.instance;
    await session.configure(const as_session.AudioSessionConfiguration(
      avAudioSessionCategory: as_session.AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions:
          as_session.AVAudioSessionCategoryOptions.duckOthers,
      avAudioSessionMode: as_session.AVAudioSessionMode.defaultMode,
      androidAudioAttributes: as_session.AndroidAudioAttributes(
        contentType: as_session.AndroidAudioContentType.music,
        flags: as_session.AndroidAudioFlags.audibilityEnforced,
        usage: as_session.AndroidAudioUsage.alarm,
      ),
      androidAudioFocusGainType:
          as_session.AndroidAudioFocusGainType.gainTransient,
      androidWillPauseWhenDucked: true,
    ));

    await _showAdhanNotification(prayerName);

    // Update Widget to sync state (Next prayer, etc.)
    await HomeWidgetService.updatePrayerWidget();

    try {
      log("AdhanService: Playing adhan file: adhan/$fileName");
      await _player.play(AssetSource("adhan/$fileName"));
    } catch (e) {
      log("AdhanService: Play error: $e");
    }
  }

  @pragma('vm:entry-point')
  static void playPreAdhanCallback() async {
    WidgetsFlutterBinding.ensureInitialized();
    initializeIsolateListener();
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('isPreAdhanEnabled') ?? false)) return;

    final now = DateTime.now();
    final leadMinutes = prefs.getInt('preAdhanMinutes') ?? 15;
    final checkTime = now.add(Duration(minutes: leadMinutes));

    Timings? timings;

    // 1. Try to load from CalendarModel
    final calendarJson = prefs.getString('CalendarModel');
    if (calendarJson != null) {
      try {
        final calendarModel = CalendarModel.fromJson(jsonDecode(calendarJson));
        // Use checkTime to find the correct day (in case lead time pushes to next day, though unlikely for 15 mins)
        // Actually, better to use 'now' or 'checkTime' date.
        // Prayer times are relative to the day they belong to.
        final targetDate = checkTime;
        final dateStr =
            "${targetDate.day.toString().padLeft(2, '0')}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.year}";

        final dayData = calendarModel.data.firstWhere(
          (element) => element.date.gregorian.date == dateStr,
        );
        timings = dayData.timings;
      } catch (e) {
        log("Error loading calendar in pre-callback: $e");
      }
    }

    // 2. Fallback
    if (timings == null) {
      final timesJson = prefs.getString('TimesModel');
      if (timesJson != null) {
        final timesModel = TimesModel.fromJson(jsonDecode(timesJson));
        timings = timesModel.data.timings;
      }
    }

    if (timings == null) return;

    // ---------------------------------------------------------
    // ROBUST PRE-PRAYER DETECTION LOGIC
    // ---------------------------------------------------------
    String prayerName = "";
    String fileName = "";
    int minDiffMinutes = 9999;

    var prayers = {
      "الفجر": timings.fajr,
      "الظهر": timings.dhuhr,
      "العصر": timings.asr,
      "المغرب": timings.maghrib,
      "العشاء": timings.isha,
    };

    // Helper to parse target day's time
    // We use checkTime's date components because timings belong to that day
    DateTime? parseTargetTime(String t) {
      try {
        final clean = t.split(' ')[0].trim();
        final parts = clean.split(':');
        return DateTime(checkTime.year, checkTime.month, checkTime.day,
            int.parse(parts[0]), int.parse(parts[1]));
      } catch (_) {
        return null;
      }
    }

    prayers.forEach((pName, pTimeStr) {
      final pDate = parseTargetTime(pTimeStr);
      if (pDate != null) {
        final diff = checkTime.difference(pDate).inMinutes.abs();
        // Tight window: 5 minutes to avoid matching wrong prayer
        if (diff < 5 && diff < minDiffMinutes) {
          minDiffMinutes = diff;
          prayerName = pName;
        }
      }
    });

    log("AdhanService: Detected Pre-Prayer: $prayerName (Diff: $minDiffMinutes min)");

    if (prayerName == "الفجر") {
      fileName = "pre_fajr.mp3";
    } else if (prayerName == "الظهر") {
      // Check for Jumuah (Friday)
      if (checkTime.weekday == DateTime.friday) {
        prayerName = "الجمعة";
        fileName = "pre_jumuah.mp3";
      } else {
        fileName = "pre_dhuhr.mp3";
      }
    } else if (prayerName == "العصر") {
      fileName = "pre_asr.mp3";
    } else if (prayerName == "المغرب") {
      fileName = "pre_maghrib.mp3";
    } else if (prayerName == "العشاء") {
      fileName = "pre_isha.mp3";
    }
    // ---------------------------------------------------------

    if (prayerName.isEmpty || fileName.isEmpty) return;

    // Configure AudioSession for Alarm usage (Pre-Adhan)
    final session = await as_session.AudioSession.instance;
    await session.configure(const as_session.AudioSessionConfiguration(
      avAudioSessionCategory: as_session.AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions:
          as_session.AVAudioSessionCategoryOptions.duckOthers,
      avAudioSessionMode: as_session.AVAudioSessionMode.defaultMode,
      androidAudioAttributes: as_session.AndroidAudioAttributes(
        contentType: as_session.AndroidAudioContentType.music,
        flags: as_session.AndroidAudioFlags.audibilityEnforced,
        usage: as_session.AndroidAudioUsage.alarm,
      ),
      androidAudioFocusGainType:
          as_session.AndroidAudioFocusGainType.gainTransient,
      androidWillPauseWhenDucked: true,
    ));

    await _showPreAdhanNotification(prayerName, leadMinutes);

    // Update Widget to sync state
    await HomeWidgetService.updatePrayerWidget();

    try {
      log("AdhanService: Playing pre-adhan file: adhan/$fileName");
      await _player.play(AssetSource("adhan/$fileName"));
    } catch (e) {
      log("AdhanService: Pre-Adhan Play error: $e");
    }
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

  static bool _isScheduling = false;

  static Future<void> scheduleAdhans([TimesModel? timesModel]) async {
    if (_isScheduling) {
      log("AdhanService: scheduleAdhans already running. Skipping...");
      return;
    }
    _isScheduling = true;

    try {
      log("AdhanService: Starting scheduleAdhans...");
      final prefs = await SharedPreferences.getInstance();

      // Try to get calendar data for multi-day scheduling
      CalendarModel? calendarModel;
      final calendarJson = prefs.getString('CalendarModel');
      if (calendarJson != null) {
        try {
          calendarModel = CalendarModel.fromJson(jsonDecode(calendarJson));
          log("AdhanService: Loaded CalendarModel with ${calendarModel.data.length} days");
        } catch (e) {
          log("AdhanService: Error decoding CalendarModel: $e");
        }
      }

      if (timesModel == null) {
        final timesJson = prefs.getString('TimesModel');
        if (timesJson != null) {
          timesModel = TimesModel.fromJson(jsonDecode(timesJson));
          log("AdhanService: Loaded TimesModel from cache");
        }
      }

    if (timesModel == null && calendarModel == null) {
      log("AdhanService: No prayer times data available, cannot schedule adhans!");
      return;
    }

    final now = DateTime.now();
    final isEnabled = prefs.getBool('isAdhanEnabled') ?? true;
    final isPreEnabled = prefs.getBool('isPreAdhanEnabled') ?? false;
    final preMinutes = prefs.getInt('preAdhanMinutes') ?? 15;

    DateTime parseTime(String t, DateTime date) {
      if (t.isEmpty || !t.contains(':')) return date;
      try {
        final cleanTime = t.split(' ')[0];
        final p = cleanTime.split(':');
        return DateTime(date.year, date.month, date.day, int.parse(p[0].trim()),
            int.parse(p[1].trim()));
      } catch (e) {
        log("Error parsing time $t: $e");
        return date;
      }
    }

    // --- Smart Cleanup ---
    // Instead of cancelling 384 potential IDs every time, we track active IDs.
    final List<String> prevIdsStr = prefs.getStringList('active_alarm_ids') ?? [];
    final Set<int> previousAlarmIds = prevIdsStr.map((e) => int.tryParse(e) ?? 0).where((id) => id != 0).toSet();
    final Set<int> newAlarmIds = {};
    // ----------------------------------------

    // Schedule for the next 7 days to support offline usage
    for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
      final targetDate = now.add(Duration(days: dayOffset));
      final targetDateStr =
          "${targetDate.day.toString().padLeft(2, '0')}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.year}";

      Timings? dayTimings;

      // Try to find correct timings for this specific day from calendar
      if (calendarModel != null) {
        try {
          final dayData = calendarModel.data.firstWhere(
            (element) => element.date.gregorian.date == targetDateStr,
          );
          dayTimings = dayData.timings;
        } catch (_) {
          // Day not found in current month's calendar (might be next month)
        }
      }

      // Fallback to today's timings (less accurate but better than nothing)
      // only for the first 2 days if calendar is missing
      if (dayTimings == null && dayOffset <= 1 && timesModel != null) {
        dayTimings = timesModel.data.timings;
      }

      if (dayTimings == null) continue;

      final Map<String, String> prayerTimings = {
        'Fajr': dayTimings.fajr,
        'Dhuhr': dayTimings.dhuhr,
        'Asr': dayTimings.asr,
        'Maghrib': dayTimings.maghrib,
        'Isha': dayTimings.isha,
      };

      for (var entry in prayerTimings.entries) {
        final prayerTime = parseTime(entry.value, targetDate);
        final prayerId = _getPrayerId(entry.key);

        // 1. Schedule main Adhan
        if (isEnabled && prayerTime.isAfter(now)) {
          final alarmId = adhanAlarmId + (targetDate.day * 10) + prayerId;
          newAlarmIds.add(alarmId);
          bool scheduled = false;

          try {
            scheduled = await AndroidAlarmManager.oneShotAt(
              prayerTime,
              alarmId,
              playAdhanCallback,
              exact: true, // Try exact first
              wakeup: true,
              rescheduleOnReboot: true,
            );
          } catch (e) {
            log("AdhanService: Exact alarm failed ($e), retrying with non-exact...");
            // Fallback to non-exact if permission is missing
            scheduled = await AndroidAlarmManager.oneShotAt(
              prayerTime,
              alarmId,
              playAdhanCallback,
              exact: false,
              wakeup: true,
              rescheduleOnReboot: true,
            );
          }

          log("AdhanService: Scheduled ${entry.key} at $prayerTime (ID: $alarmId, success: $scheduled)");
        }

        // 2. Schedule Pre-Adhan Reminder
        if (isPreEnabled) {
          final reminderTime =
              prayerTime.subtract(Duration(minutes: preMinutes));
          if (reminderTime.isAfter(now)) {
            final alarmId = preAdhanAlarmId + (targetDate.day * 10) + prayerId;
            newAlarmIds.add(alarmId);
            bool scheduled = false;
            try {
              scheduled = await AndroidAlarmManager.oneShotAt(
                reminderTime,
                alarmId,
                playPreAdhanCallback,
                exact: true,
                wakeup: true,
                rescheduleOnReboot: true,
              );
            } catch (e) {
              log("AdhanService: Pre-Adhan exact alarm failed, retrying non-exact...");
              scheduled = await AndroidAlarmManager.oneShotAt(
                reminderTime,
                alarmId,
                playPreAdhanCallback,
                exact: false, // Fallback
                wakeup: true,
                rescheduleOnReboot: true,
              );
            }
            log("AdhanService: Scheduled Pre-${entry.key} at $reminderTime (ID: $alarmId, success: $scheduled)");
          }
        }
      }
    }

    // --- Execute Smart Cleanup ---
    // Cancel old alarms that are no longer needed
    for (int oldId in previousAlarmIds) {
      if (!newAlarmIds.contains(oldId)) {
        try {
          await AndroidAlarmManager.cancel(oldId);
        } catch (_) {}
      }
    }

    // Save newly active IDs
    await prefs.setStringList('active_alarm_ids', newAlarmIds.map((e) => e.toString()).toList());
    log("AdhanService: Smart cleanup complete. ${newAlarmIds.length} alarms are active.");
    } finally {
      _isScheduling = false;
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
