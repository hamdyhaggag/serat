import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serat/Data/utils/cache_helper.dart';
import '../models/spiritual_models.dart';
import 'package:serat/shared/services/notification_service.dart';

abstract class SpiritualState {}

class SpiritualInitial extends SpiritualState {}

class SpiritualLoading extends SpiritualState {}

class SpiritualLoaded extends SpiritualState {
  final List<SpiritualTask> tasks;
  final SpiritualStats stats;
  SpiritualLoaded(this.tasks, this.stats);
}

class SpiritualCubit extends Cubit<SpiritualState> {
  SpiritualCubit() : super(SpiritualInitial());

  static SpiritualCubit get(context) => BlocProvider.of(context);

  List<SpiritualTask> _tasks = [];
  SpiritualStats _stats = SpiritualStats();

  void init() {
    _loadData();
  }

  void _loadData() {
    emit(SpiritualLoading());

    final dynamic tasksData = CacheHelper.getData(key: 'spiritual_tasks_v3');
    final dynamic statsData = CacheHelper.getData(key: 'spiritual_stats');
    final dynamic lastUpdate = CacheHelper.getData(key: 'spiritual_last_reset');

    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    bool isNewDay = lastUpdate != todayStr;

    if (tasksData is String) {
      final List<dynamic> decoded = json.decode(tasksData);
      _tasks = decoded.map((item) => SpiritualTask.fromJson(item)).toList();
    } else {
      // Default tasks if no cache exists
      _tasks = _getDefaultTasks();
    }

    if (statsData is String) {
      _stats = SpiritualStats.fromJson(json.decode(statsData));
    }

    if (isNewDay) {
      CacheHelper.putData(key: 'spiritual_last_reset', value: todayStr);

      // ── Streak logic ──────────────────────────────────────────────────────
      // Check if yesterday had any worship activity recorded
      final yesterday = now.subtract(const Duration(days: 1));
      final yesterdayKey =
          '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
      final hadActivityYesterday = _stats.weeklyData.containsKey(yesterdayKey) &&
          (_stats.weeklyData[yesterdayKey]!.totalScore > 0);

      final newStreak = hadActivityYesterday ? _stats.streakDays + 1 : 0;
      _stats = _stats.copyWith(streakDays: newStreak);
      // ──────────────────────────────────────────────────────────────────────

      // Reset daily task counts but keep goals/times
      for (int i = 0; i < _tasks.length; i++) {
        _tasks[i] = _tasks[i].copyWith(currentCount: 0);
      }
      _saveData();
    }

    emit(SpiritualLoaded(List.from(_tasks), _stats));

    // Re-schedule all reminders after a short delay so AdhanService
    // (which calls cancelAllNotifications) runs first.
    Future.delayed(const Duration(seconds: 5), _reScheduleAllReminders);
  }

  Future<void> _reScheduleAllReminders() async {
    final tasksWithReminders = _tasks.where((t) => t.reminderTime != null).toList();
    if (tasksWithReminders.isEmpty) return;
    developer.log(
      'Re-scheduling ${tasksWithReminders.length} reminder(s) on app load...',
      name: 'SpiritualCubit',
    );
    for (final task in tasksWithReminders) {
      await _scheduleReminder(task);
    }
  }

  List<SpiritualTask> _getDefaultTasks() {
    return [
      SpiritualTask(
        id: 'prayer_5',
        title: 'الصلوات الخمس',
        subtitle: 'أقم صلاتك لوقتها',
        category: TaskCategory.fard,
        targetCount: 5,
        icon: Icons.mosque_rounded,
        color: const Color(0xff2196F3),
      ),
      SpiritualTask(
        id: 'sunnah',
        title: 'السنن والرواتب',
        subtitle: 'عوض ما فاتك ونل الأجر',
        category: TaskCategory.sunnah,
        targetCount: 12,
        icon: Icons.auto_awesome_rounded,
        color: const Color(0xffFF9800),
      ),
      SpiritualTask(
        id: 'quran_daily',
        title: 'ورد القرآن',
        subtitle: 'لا تهجر كتاب الله',
        category: TaskCategory.quran,
        targetCount: 10,
        icon: Icons.menu_book_rounded,
        color: const Color(0xff4CAF50),
      ),
      SpiritualTask(
        id: 'adhkar_morning',
        title: 'أذكار الصباح',
        subtitle: 'حصن نفسك في بداية يومك',
        category: TaskCategory.adhkar,
        targetCount: 1,
        icon: Icons.wb_sunny_rounded,
        color: const Color(0xffFFC107),
      ),
      SpiritualTask(
        id: 'adhkar_evening',
        title: 'أذكار المساء',
        subtitle: 'اختم يومك بذكر الله',
        category: TaskCategory.adhkar,
        targetCount: 1,
        icon: Icons.nights_stay_rounded,
        color: const Color(0xff3F51B5),
      ),
    ];
  }

  void _saveData() {
    final tasksList = _tasks.map((t) => t.toJson()).toList();
    CacheHelper.putData(
        key: 'spiritual_tasks_v3', value: json.encode(tasksList));
    CacheHelper.putData(
        key: 'spiritual_stats', value: json.encode(_stats.toJson()));
  }

  Future<void> addTask(SpiritualTask task) async {
    _tasks.add(task);
    _saveData();
    if (task.reminderTime != null) {
      await _scheduleReminder(task);
    }
    emit(SpiritualLoaded(List.from(_tasks), _stats));
  }

  void deleteTask(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final task = _tasks[index];
      _tasks.removeAt(index);
      _cancelReminder(task);
      _saveData();
      emit(SpiritualLoaded(List.from(_tasks), _stats));
    }
  }

  Future<void> updateTask(String id,
      {int? count,
      String? reminderTime,
      int? targetCount,
      String? title,
      String? subtitle}) async {
    if (state is SpiritualLoaded) {
      final index = _tasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        final oldTask = _tasks[index];

        // Handle reminder changes
        if (reminderTime != oldTask.reminderTime) {
          _cancelReminder(oldTask);
        }

        final newTask = oldTask.copyWith(
          currentCount: count,
          reminderTime: reminderTime,
          targetCount: targetCount,
          title: title,
          subtitle: subtitle,
        );

        _tasks[index] = newTask;

        if (reminderTime != null && reminderTime != oldTask.reminderTime) {
          await _scheduleReminder(newTask);
        }

        // Update stats if task is newly completed
        if (count != null &&
            count >= newTask.targetCount &&
            oldTask.currentCount < oldTask.targetCount) {
          _updateStatsForTask(oldTask.category);
        }

        _saveData();
        emit(SpiritualLoaded(List.from(_tasks), _stats));
      }
    }
  }

  void reorderTasks(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final task = _tasks.removeAt(oldIndex);
    _tasks.insert(newIndex, task);
    _saveData();
    emit(SpiritualLoaded(List.from(_tasks), _stats));
  }

  Future<void> _scheduleReminder(SpiritualTask task) async {
    if (task.reminderTime == null) return;
    try {
      // Ensure permissions are granted before scheduling
      await NotificationService().requestPermissions();

      final notificationId = task.id.hashCode.abs();
      await NotificationService().scheduleSpiritualTaskReminder(
        id: notificationId,
        title: 'موعد العبادة: ${task.title}',
        body: task.subtitle,
        timeString: task.reminderTime!,
      );
      developer.log(
        'Reminder scheduled for "${task.title}" at ${task.reminderTime} (id=$notificationId)',
        name: 'SpiritualCubit',
      );
    } catch (e) {
      developer.log(
        'Failed to schedule reminder for "${task.title}": $e',
        name: 'SpiritualCubit',
        error: e,
      );
    }
  }

  Future<void> _cancelReminder(SpiritualTask task) async {
    final notificationId = task.id.hashCode.abs();
    await NotificationService().cancelNotification(notificationId);
  }

  void updateStats(
      {double? quranMinutes,
      int? adhkarCount,
      int? prayerCount,
      int? sunnahCount,
      double? totalWorshipMinutes}) {
    final now = DateTime.now();
    final todayKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    // Update the aggregate totals
    final newStats = _stats.copyWith(
      quranMinutes:
          quranMinutes != null ? _stats.quranMinutes + quranMinutes : null,
      adhkarCount:
          adhkarCount != null ? _stats.adhkarCount + adhkarCount : null,
      prayerCount:
          prayerCount != null ? _stats.prayerCount + prayerCount : null,
      sunnahCount:
          sunnahCount != null ? _stats.sunnahCount + sunnahCount : null,
      totalWorshipMinutes:
          totalWorshipMinutes != null ? _stats.totalWorshipMinutes + totalWorshipMinutes : null,
    );

    // Update today's DailyRecord inside weeklyData
    final existingDay =
        newStats.weeklyData[todayKey] ?? DailyRecord(dateKey: todayKey);
    final updatedDay = existingDay.copyWith(
      quranMinutes:
          quranMinutes != null ? existingDay.quranMinutes + quranMinutes : null,
      adhkarCount:
          adhkarCount != null ? existingDay.adhkarCount + adhkarCount : null,
      prayerCount:
          prayerCount != null ? existingDay.prayerCount + prayerCount : null,
      sunnahCount:
          sunnahCount != null ? existingDay.sunnahCount + sunnahCount : null,
      totalWorshipMinutes:
          totalWorshipMinutes != null ? existingDay.totalWorshipMinutes + totalWorshipMinutes : null,
    );

    // Keep only last 7 days
    final updatedWeekly = Map<String, DailyRecord>.from(newStats.weeklyData);
    updatedWeekly[todayKey] = updatedDay;
    if (updatedWeekly.length > 7) {
      final keys = updatedWeekly.keys.toList()..sort();
      updatedWeekly.remove(keys.first);
    }

    _stats = newStats.copyWith(weeklyData: updatedWeekly);
    _saveData();
    emit(SpiritualLoaded(List.from(_tasks), _stats));
  }

  void resetStats() {
    _stats = SpiritualStats();
    _saveData();
    emit(SpiritualLoaded(List.from(_tasks), _stats));
  }

  void _updateStatsForTask(TaskCategory category) {
    // When a task is completed in the dashboard, update the weekly stats
    switch (category) {
      case TaskCategory.quran:
        // We'll give a default of 5 minutes for completing a Quran task if not specified
        updateStats(quranMinutes: 5.0, totalWorshipMinutes: 5.0);
        break;
      case TaskCategory.adhkar:
        updateStats(adhkarCount: 1);
        break;
      case TaskCategory.fard:
        updateStats(prayerCount: 1);
        break;
      case TaskCategory.sunnah:
        updateStats(sunnahCount: 1);
        break;
      case TaskCategory.other:
        // For other tasks, maybe just add to total worship time?
        updateStats(totalWorshipMinutes: 2.0);
        break;
    }
  }
}
