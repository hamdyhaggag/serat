import 'dart:convert';

/// A model class representing a daily goal in the application.
class DailyGoal {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;
  final double progress;

  DailyGoal({
    String? id,
    required this.title,
    required this.subtitle,
    required this.category,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
    this.progress = 0.0,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  /// Creates a copy of this DailyGoal with the given fields replaced with the new values.
  DailyGoal copyWith({
    String? title,
    String? subtitle,
    String? category,
    bool? isCompleted,
    DateTime? completedAt,
    double? progress,
  }) {
    return DailyGoal(
      id: id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
      progress: progress ?? this.progress,
    );
  }

  /// Converts the DailyGoal to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'category': category,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'progress': progress,
    };
  }

  /// Creates a DailyGoal from a JSON map.
  factory DailyGoal.fromJson(Map<String, dynamic> json) {
    return DailyGoal(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      category: json['category'],
      isCompleted: json['isCompleted'],
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      progress: json['progress'],
    );
  }

  /// Converts the DailyGoal to a JSON string.
  String toJsonString() => json.encode(toJson());

  /// Creates a DailyGoal from a JSON string.
  factory DailyGoal.fromJsonString(String source) =>
      DailyGoal.fromJson(json.decode(source));
}
