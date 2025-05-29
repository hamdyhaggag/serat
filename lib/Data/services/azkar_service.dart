import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:serat/features/azkar/domain/azkar_model.dart';

class AzkarService {
  static Future<List<AzkarCategory>> loadAzkar() async {
    try {
      print('Loading Azkar data...');
      // Load the JSON file from assets
      final String jsonString =
          await rootBundle.loadString('assets/data/adhkar.json');
      print('JSON string loaded, length: ${jsonString.length}');

      // Parse the JSON string into a List
      final List<dynamic> jsonData = json.decode(jsonString);
      print('JSON parsed, number of categories: ${jsonData.length}');

      // Convert the data into a list of AzkarCategory objects
      List<AzkarCategory> categories = jsonData.map((category) {
        print('Processing category: ${category['category']}');
        return AzkarCategory.fromJson(category);
      }).toList();

      print('Categories processed: ${categories.length}');
      return categories;
    } catch (e, stackTrace) {
      print('Error loading Azkar data: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  static Future<AzkarCategory?> getAzkarByCategory(String categoryName) async {
    final categories = await loadAzkar();
    return categories.firstWhere(
      (category) => category.folderName == categoryName,
      orElse: () => throw Exception('Category not found'),
    );
  }

  static Future<List<String>> getAllCategories() async {
    final categories = await loadAzkar();
    return categories.map((category) => category.folderName).toList();
  }
}
