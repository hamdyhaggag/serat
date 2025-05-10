class AzkarItem {
  final String text;
  final int count;
  final String reward;
  final bool isDefault;

  AzkarItem({
    required this.text,
    required this.count,
    required this.reward,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        'count': count,
        'reward': reward,
        'isDefault': isDefault,
      };

  factory AzkarItem.fromJson(Map<String, dynamic> json) => AzkarItem(
        text: json['text'],
        count: json['count'],
        reward: json['reward'],
        isDefault: json['isDefault'],
      );
}
