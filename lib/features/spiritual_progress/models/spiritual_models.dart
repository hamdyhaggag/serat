import 'package:flutter/material.dart';

enum TaskCategory { fard, sunnah, quran, adhkar, other }

// ─── Spiritual Task ────────────────────────────────────────────────────────────

class SpiritualTask {
  final String id;
  final String title;
  final String subtitle;
  final TaskCategory category;
  final int targetCount;
  final int currentCount;
  final IconData icon;
  final Color color;
  final String? reminderTime; // "HH:mm"
  final bool isCustom;

  SpiritualTask({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.targetCount,
    this.currentCount = 0,
    required this.icon,
    required this.color,
    this.reminderTime,
    this.isCustom = false,
  });

  double get progress =>
      targetCount == 0 ? 0 : (currentCount / targetCount).clamp(0.0, 1.0);

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'category': category.index,
        'targetCount': targetCount,
        'currentCount': currentCount,
        'iconCode': icon.codePoint,
        'iconFamily': icon.fontFamily,
        'colorValue': color.value,
        'reminderTime': reminderTime,
        'isCustom': isCustom,
      };

  factory SpiritualTask.fromJson(Map<String, dynamic> json) => SpiritualTask(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        subtitle: json['subtitle'] ?? '',
        category: TaskCategory.values[json['category'] ?? 0],
        targetCount: json['targetCount'] ?? 1,
        currentCount: json['currentCount'] ?? 0,
        icon: IconData(
          json['iconCode'] ?? Icons.task_alt.codePoint,
          fontFamily: json['iconFamily'] ?? 'MaterialIcons',
        ),
        color: Color(json['colorValue'] ?? Colors.blue.value),
        reminderTime: json['reminderTime'],
        isCustom: json['isCustom'] ?? false,
      );

  SpiritualTask copyWith({
    int? currentCount,
    String? reminderTime,
    String? title,
    String? subtitle,
    int? targetCount,
  }) {
    return SpiritualTask(
      id: id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      category: category,
      targetCount: targetCount ?? this.targetCount,
      currentCount: currentCount ?? this.currentCount,
      icon: icon,
      color: color,
      reminderTime: reminderTime ?? this.reminderTime,
      isCustom: isCustom,
    );
  }
}

// ─── Daily Record ──────────────────────────────────────────────────────────────

/// Represents the worship statistics for a single day.
class DailyRecord {
  final String dateKey; // "yyyy-MM-dd"
  final double quranMinutes;
  final int adhkarCount;
  final int prayerCount;
  final int sunnahCount;
  final double totalWorshipMinutes;

  DailyRecord({
    required this.dateKey,
    this.quranMinutes = 0,
    this.adhkarCount = 0,
    this.prayerCount = 0,
    this.sunnahCount = 0,
    this.totalWorshipMinutes = 0,
  });

  /// A single "effort score" to render in the bar chart.
  double get totalScore =>
      totalWorshipMinutes + (adhkarCount * 0.1) + (prayerCount * 10.0) + (sunnahCount * 2.0);

  Map<String, dynamic> toJson() => {
        'dateKey': dateKey,
        'quranMinutes': quranMinutes,
        'adhkarCount': adhkarCount,
        'prayerCount': prayerCount,
        'sunnahCount': sunnahCount,
        'totalWorshipMinutes': totalWorshipMinutes,
      };

  factory DailyRecord.fromJson(Map<String, dynamic> json) => DailyRecord(
        dateKey: json['dateKey'] ?? '',
        quranMinutes: (json['quranMinutes'] ?? 0).toDouble(),
        adhkarCount: json['adhkarCount'] ?? 0,
        prayerCount: json['prayerCount'] ?? 0,
        sunnahCount: json['sunnahCount'] ?? 0,
        totalWorshipMinutes: (json['totalWorshipMinutes'] ?? (json['quranMinutes'] ?? 0)).toDouble(),
      );

  DailyRecord copyWith({
    double? quranMinutes,
    int? adhkarCount,
    int? prayerCount,
    int? sunnahCount,
    double? totalWorshipMinutes,
  }) {
    return DailyRecord(
      dateKey: dateKey,
      quranMinutes: quranMinutes ?? this.quranMinutes,
      adhkarCount: adhkarCount ?? this.adhkarCount,
      prayerCount: prayerCount ?? this.prayerCount,
      sunnahCount: sunnahCount ?? this.sunnahCount,
      totalWorshipMinutes: totalWorshipMinutes ?? this.totalWorshipMinutes,
    );
  }
}

// ─── Spiritual Stats ───────────────────────────────────────────────────────────

class SpiritualStats {
  final double quranMinutes;
  final int adhkarCount;
  final int prayerCount;
  final int sunnahCount;
  final int streakDays;
  final double totalWorshipMinutes;

  /// Map of "yyyy-MM-dd" -> DailyRecord for per-day tracking.
  final Map<String, DailyRecord> weeklyData;

  SpiritualStats({
    this.quranMinutes = 0,
    this.adhkarCount = 0,
    this.prayerCount = 0,
    this.sunnahCount = 0,
    this.streakDays = 0,
    this.totalWorshipMinutes = 0,
    this.weeklyData = const {},
  });

  Map<String, dynamic> toJson() => {
        'quranMinutes': quranMinutes,
        'adhkarCount': adhkarCount,
        'prayerCount': prayerCount,
        'sunnahCount': sunnahCount,
        'streakDays': streakDays,
        'totalWorshipMinutes': totalWorshipMinutes,
        'weeklyData': weeklyData.map((k, v) => MapEntry(k, v.toJson())),
      };

  factory SpiritualStats.fromJson(Map<String, dynamic> json) {
    final Map<String, DailyRecord> weekly = {};
    if (json['weeklyData'] != null) {
      (json['weeklyData'] as Map<String, dynamic>).forEach((k, v) {
        weekly[k] = DailyRecord.fromJson(v as Map<String, dynamic>);
      });
    }
    return SpiritualStats(
      quranMinutes: (json['quranMinutes'] ?? 0).toDouble(),
      adhkarCount: json['adhkarCount'] ?? 0,
      prayerCount: json['prayerCount'] ?? 0,
      sunnahCount: json['sunnahCount'] ?? 0,
      streakDays: json['streakDays'] ?? 0,
      totalWorshipMinutes: (json['totalWorshipMinutes'] ?? (json['quranMinutes'] ?? 0)).toDouble(),
      weeklyData: weekly,
    );
  }

  SpiritualStats copyWith({
    double? quranMinutes,
    int? adhkarCount,
    int? prayerCount,
    int? sunnahCount,
    int? streakDays,
    double? totalWorshipMinutes,
    Map<String, DailyRecord>? weeklyData,
  }) {
    return SpiritualStats(
      quranMinutes: quranMinutes ?? this.quranMinutes,
      adhkarCount: adhkarCount ?? this.adhkarCount,
      prayerCount: prayerCount ?? this.prayerCount,
      sunnahCount: sunnahCount ?? this.sunnahCount,
      streakDays: streakDays ?? this.streakDays,
      totalWorshipMinutes: totalWorshipMinutes ?? this.totalWorshipMinutes,
      weeklyData: weeklyData ?? this.weeklyData,
    );
  }
}
