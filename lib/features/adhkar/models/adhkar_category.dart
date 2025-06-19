class AdhkarCategory {
  final int id;
  final String category;
  final List<AdhkarItem> array;

  AdhkarCategory({
    required this.id,
    required this.category,
    required this.array,
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
}

class AdhkarItem {
  final int id;
  final String text;
  final int count;
  final String? audio;
  final String? filename;

  AdhkarItem({
    required this.id,
    required this.text,
    required this.count,
    this.audio,
    this.filename,
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
}
