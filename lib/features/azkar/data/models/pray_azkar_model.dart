class PrayAzkarModel {
  final String id;
  final String text;
  final int count;
  final String category;

  PrayAzkarModel({
    required this.id,
    required this.text,
    required this.count,
    required this.category,
  });

  factory PrayAzkarModel.fromJson(Map<String, dynamic> json) {
    return PrayAzkarModel(
      id: json['id'],
      text: json['text'],
      count: json['count'],
      category: json['category'],
    );
  }
}

class PrayAzkarCategory {
  final String folderName;
  final List<PrayAzkarModel> azkar;

  PrayAzkarCategory({required this.folderName, required this.azkar});

  factory PrayAzkarCategory.fromJson(Map<String, dynamic> json) {
    return PrayAzkarCategory(
      folderName: json['folder_name'],
      azkar:
          (json['azkar'] as List)
              .map((item) => PrayAzkarModel.fromJson(item))
              .toList(),
    );
  }
}

class PrayAzkarData {
  final Map<String, PrayAzkarCategory> categories;

  PrayAzkarData({required this.categories});

  factory PrayAzkarData.fromJson(Map<String, dynamic> json) {
    Map<String, PrayAzkarCategory> categories = {};
    json['categories'].forEach((key, value) {
      categories[key] = PrayAzkarCategory.fromJson(value);
    });
    return PrayAzkarData(categories: categories);
  }
}
