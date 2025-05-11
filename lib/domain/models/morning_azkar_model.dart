class MorningAzkarModel {
  final String? headtitle;
  final String title;
  final int maxValue;
  int initialCounterValue;

  MorningAzkarModel({
    this.headtitle,
    required this.title,
    required this.maxValue,
    required this.initialCounterValue,
  });

  factory MorningAzkarModel.fromJson(Map<String, dynamic> json) {
    return MorningAzkarModel(
      headtitle: json['headtitle'],
      title: json['title'],
      maxValue: json['maxValue'],
      initialCounterValue: json['initialCounterValue'],
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
