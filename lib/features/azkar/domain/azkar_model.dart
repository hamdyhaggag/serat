class Azkar {
  final String id;
  final String text;
  final String category;
  final int count;
  final String benefit;

  Azkar({
    required this.id,
    required this.text,
    required this.category,
    required this.count,
    required this.benefit,
  });

  factory Azkar.fromJson(Map<String, dynamic> json) {
    return Azkar(
      id: json['id'] as String,
      text: json['text'] as String,
      category: json['category'] as String,
      count: json['count'] as int,
      benefit: json['benefit'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'category': category,
      'count': count,
      'benefit': benefit,
    };
  }
}
