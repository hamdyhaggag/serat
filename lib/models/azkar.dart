class Zikr {
  final String? text;
  final int count;
  final String? benefit;
  final String? category;

  Zikr({
    this.text,
    required this.count,
    this.benefit,
    this.category,
  });

  factory Zikr.fromJson(Map<String, dynamic> json) {
    return Zikr(
      text: json['text'] as String?,
      count: json['count'] is int
          ? json['count'] as int
          : int.tryParse(json['count']?.toString() ?? '1') ?? 1,
      benefit: json['benefit'] as String?,
      category: json['category'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'count': count,
      'benefit': benefit,
      'category': category,
    };
  }
}
