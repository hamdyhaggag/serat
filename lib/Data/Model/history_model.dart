class HistoryModel {
  final int id;
  final String title;
  final List<String> date;
  final String text;

  HistoryModel({
    required this.id,
    required this.title,
    required this.date,
    required this.text,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      date: List<String>.from(json['date'] ?? []),
      text: json['text'] ?? '',
    );
  }
}
