class MorningAzkar {
  final String? headtitle;
  final String title;
  final int maxValue;
  final int initialCounterValue;

  MorningAzkar({
    this.headtitle,
    required this.title,
    required this.maxValue,
    required this.initialCounterValue,
  });

  factory MorningAzkar.fromJson(Map<String, dynamic> json) {
    return MorningAzkar(
      headtitle: json['headtitle'] as String?,
      title: json['title'] as String,
      maxValue: json['maxValue'] as int,
      initialCounterValue: json['initialCounterValue'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'headtitle': headtitle,
      'title': title,
      'maxValue': maxValue,
      'initialCounterValue': initialCounterValue,
    };
  }
}
