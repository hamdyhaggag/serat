class Azkar {
  final String id;
  final String text;
  final String? category;
  final int count;
  final String? benefit;
  final bool isDefault;
  final String? audio;
  final String? filename;

  Azkar({
    required this.id,
    required this.text,
    this.category,
    required this.count,
    this.benefit,
    this.isDefault = false,
    this.audio,
    this.filename,
  });

  factory Azkar.fromJson(Map<String, dynamic> json) {
    return Azkar(
      id: json['id']?.toString() ?? '',
      text: json['text'] as String,
      category: json['category'] as String?,
      count: json['count'] is int
          ? json['count']
          : int.tryParse(json['count']?.toString() ?? '1') ?? 1,
      benefit: json['benefit'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
      audio: json['audio'] as String?,
      filename: json['filename'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'category': category,
      'count': count,
      'benefit': benefit,
      'isDefault': isDefault,
      'audio': audio,
      'filename': filename,
    };
  }
}

class AzkarCategory {
  final String folderName;
  final List<Azkar> azkar;

  AzkarCategory({required this.folderName, required this.azkar});

  factory AzkarCategory.fromJson(Map<String, dynamic> json) {
    return AzkarCategory(
      folderName: json['category'] as String,
      azkar:
          (json['array'] as List).map((item) => Azkar.fromJson(item)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': folderName,
      'array': azkar.map((item) => item.toJson()).toList(),
    };
  }
}

class AzkarData {
  final Map<String, AzkarCategory> categories;

  AzkarData({required this.categories});

  factory AzkarData.fromJson(Map<String, dynamic> json) {
    Map<String, AzkarCategory> categories = {};
    json['categories'].forEach((key, value) {
      categories[key] = AzkarCategory.fromJson(value);
    });
    return AzkarData(categories: categories);
  }
}
