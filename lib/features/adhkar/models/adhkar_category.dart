class AdhkarCategory {
  final int id;
  final String category;
  final List<AdhkarItem> array;
  final double progress;
  final bool isCompleted;

  AdhkarCategory({
    required this.id,
    required this.category,
    required this.array,
    this.progress = 0.0,
    this.isCompleted = false,
  });

  factory AdhkarCategory.fromJson(Map<String, dynamic> json) {
    return AdhkarCategory(
      id: json['id'],
      category: json['category'],
      array: (json['array'] as List)
          .map((item) => AdhkarItem.fromJson(item))
          .toList(),
    );
  }

  AdhkarCategory copyWith({
    int? id,
    String? category,
    List<AdhkarItem>? array,
    double? progress,
    bool? isCompleted,
  }) {
    return AdhkarCategory(
      id: id ?? this.id,
      category: category ?? this.category,
      array: array ?? this.array,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class AdhkarItem {
  final int id;
  final String text;
  final int count;
  final String? audio;
  final String? filename;
  final int completedCount;
  final bool isCompleted;

  AdhkarItem({
    required this.id,
    required this.text,
    required this.count,
    this.audio,
    this.filename,
    this.completedCount = 0,
    this.isCompleted = false,
  });

  factory AdhkarItem.fromJson(Map<String, dynamic> json) {
    return AdhkarItem(
      id: json['id'],
      text: json['text'],
      count: json['count'],
      audio: json['audio'],
      filename: json['filename'],
    );
  }

  AdhkarItem copyWith({
    int? id,
    String? text,
    int? count,
    String? audio,
    String? filename,
    int? completedCount,
    bool? isCompleted,
  }) {
    return AdhkarItem(
      id: id ?? this.id,
      text: text ?? this.text,
      count: count ?? this.count,
      audio: audio ?? this.audio,
      filename: filename ?? this.filename,
      completedCount: completedCount ?? this.completedCount,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  double get progressPercentage => count > 0 ? completedCount / count : 0.0;
}

enum AdhkarViewMode {
  list,
  horizontal,
}
