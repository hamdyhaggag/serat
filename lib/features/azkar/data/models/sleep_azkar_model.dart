class SleepAzkarModel {
  final String id;
  final String text;
  final int count;
  final String category;

  SleepAzkarModel({
    required this.id,
    required this.text,
    required this.count,
    required this.category,
  });

  factory SleepAzkarModel.fromJson(Map<String, dynamic> json) {
    return SleepAzkarModel(
      id: json['id'],
      text: json['text'],
      count: json['count'],
      category: json['category'],
    );
  }
}

class SleepAzkarCategory {
  final String folderName;
  final List<SleepAzkarModel> azkar;

  SleepAzkarCategory({
    required this.folderName,
    required this.azkar,
  });

  factory SleepAzkarCategory.fromJson(Map<String, dynamic> json) {
    return SleepAzkarCategory(
      folderName: json['folder_name'],
      azkar: (json['azkar'] as List)
          .map((item) => SleepAzkarModel.fromJson(item))
          .toList(),
    );
  }
}

class SleepAzkarData {
  final Map<String, SleepAzkarCategory> categories;

  SleepAzkarData({required this.categories});

  factory SleepAzkarData.fromJson(Map<String, dynamic> json) {
    Map<String, SleepAzkarCategory> categories = {};
    json['categories'].forEach((key, value) {
      categories[key] = SleepAzkarCategory.fromJson(value);
    });
    return SleepAzkarData(categories: categories);
  }
} 