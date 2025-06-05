class NamesOfAllahModel {
  final String name;
  final String text;

  const NamesOfAllahModel({
    required this.name,
    required this.text,
  });

  factory NamesOfAllahModel.fromJson(Map<String, dynamic> json) {
    return NamesOfAllahModel(
      name: json['name'] as String,
      text: json['text'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'text': text,
    };
  }
}
