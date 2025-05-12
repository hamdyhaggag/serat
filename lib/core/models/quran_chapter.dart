class QuranChapter {
  final int number;
  final String name;
  final String englishName;
  final String englishNameTranslation;
  final int versesCount;
  final String revelationType;

  QuranChapter({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.versesCount,
    required this.revelationType,
  });

  factory QuranChapter.fromJson(Map<String, dynamic> json) {
    return QuranChapter(
      number: json['number'],
      name: json['name'],
      englishName: json['englishName'],
      englishNameTranslation: json['englishNameTranslation'],
      versesCount: json['numberOfAyahs'],
      revelationType: json['revelationType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'name': name,
      'englishName': englishName,
      'englishNameTranslation': englishNameTranslation,
      'numberOfAyahs': versesCount,
      'revelationType': revelationType,
    };
  }
}
