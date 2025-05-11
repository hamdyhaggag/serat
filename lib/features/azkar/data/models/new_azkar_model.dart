import 'dart:convert';

class NewAzkarModel {
  final Map<String, Category> categories;

  NewAzkarModel({required this.categories});

  factory NewAzkarModel.fromJson(Map<String, dynamic> json) {
    final categories = <String, Category>{};
    json['categories'].forEach((key, value) {
      categories[key] = Category.fromJson(value);
    });
    return NewAzkarModel(categories: categories);
  }

  Map<String, dynamic> toJson() {
    return {
      'categories': categories.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
    };
  }
}

class Category {
  final String folderName;
  final List<Azkar> azkar;

  Category({required this.folderName, required this.azkar});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      folderName: json['folderName'],
      azkar:
          (json['azkar'] as List)
              .map((azkar) => Azkar.fromJson(azkar))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'folderName': folderName,
      'azkar': azkar.map((azkar) => azkar.toJson()).toList(),
    };
  }
}

class Azkar {
  final String text;
  final int count;

  Azkar({required this.text, required this.count});

  factory Azkar.fromJson(Map<String, dynamic> json) {
    return Azkar(text: json['text'], count: json['count']);
  }

  Map<String, dynamic> toJson() {
    return {'text': text, 'count': count};
  }
}
