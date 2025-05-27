class QuranVerse {
  final int number;
  final Map<String, String> text;
  final int juz;
  final int page;
  final SajdaInfo? sajda;

  QuranVerse({
    required this.number,
    required this.text,
    required this.juz,
    required this.page,
    this.sajda,
  });

  factory QuranVerse.fromJson(Map<String, dynamic> json) {
    return QuranVerse(
      number: json['number'] ?? 0,
      text: Map<String, String>.from(json['text'] ?? {}),
      juz: json['juz'] ?? 0,
      page: json['page'] ?? 0,
      sajda: json['sajda'] is Map ? SajdaInfo.fromJson(json['sajda']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'text': text,
      'juz': juz,
      'page': page,
      'sajda': sajda?.toJson(),
    };
  }
}

class SajdaInfo {
  final bool obligatory;
  final String? reason;

  SajdaInfo({
    required this.obligatory,
    this.reason,
  });

  factory SajdaInfo.fromJson(Map<String, dynamic> json) {
    return SajdaInfo(
      obligatory: json['obligatory'] ?? false,
      reason: json['reason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'obligatory': obligatory,
      'reason': reason,
    };
  }
}
