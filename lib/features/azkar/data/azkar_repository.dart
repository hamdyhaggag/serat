import 'dart:convert';
import 'package:flutter/services.dart';
import '../domain/azkar_model.dart';

class AzkarRepository {
  Future<List<AzkarCategory>> getAllCategories() async {
    final String response =
        await rootBundle.loadString('assets/data/adhkar.json');
    final List<dynamic> data = json.decode(response);
    return data.map((json) => AzkarCategory.fromJson(json)).toList();
  }

  Future<AzkarCategory?> getAzkarByCategory(String categoryName) async {
    final categories = await getAllCategories();
    try {
      return categories.firstWhere((cat) => cat.folderName == categoryName);
    } catch (e) {
      return null;
    }
  }
}
