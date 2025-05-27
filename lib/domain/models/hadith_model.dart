class HadithModel {
  final int id;
  final String hadithNumber;
  final String hadithText;
  final String explanation;
  final String narrator;
  final String chapterName;

  HadithModel({
    required this.id,
    required this.hadithNumber,
    required this.hadithText,
    required this.explanation,
    required this.narrator,
    required this.chapterName,
  });

  factory HadithModel.fromJson(Map<String, dynamic> json) {
    return HadithModel(
      id: json['id'] as int,
      hadithNumber: json['hadithNumber'] as String,
      hadithText: json['hadithText'] as String,
      explanation: json['explanation'] as String,
      narrator: json['narrator'] as String,
      chapterName: json['chapterName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hadithNumber': hadithNumber,
      'hadithText': hadithText,
      'explanation': explanation,
      'narrator': narrator,
      'chapterName': chapterName,
    };
  }
}
