class AzkarModel {
  final int id;
  final String category;
  final List<Zikr> array;

  AzkarModel({
    required this.id,
    required this.category,
    required this.array,
  });

  factory AzkarModel.fromJson(Map<String, dynamic> json) {
    return AzkarModel(
      id: json['id'],
      category: json['category'],
      array: (json['array'] as List)
          .map((item) => Zikr.fromJson(item))
          .toList(),
    );
  }
}

class Zikr {
  final int id;
  final String text;
  final int count;

  Zikr({
    required this.id,
    required this.text,
    required this.count,
  });

  factory Zikr.fromJson(Map<String, dynamic> json) {
    return Zikr(
      id: json['id'],
      text: json['text'],
      count: json['count'],
    );
  }
} 