import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/azkar_model.dart';

class AzkarService {
  static Future<List<AzkarModel>> loadAzkar() async {
    try {
      // Load the JSON file from assets
      final String jsonString = await rootBundle.loadString('assets/data/adhkar.json');
      
      // Parse the JSON string into a List of maps
      final List<dynamic> jsonList = json.decode(jsonString);
      
      // Convert each map into an AzkarModel object
      return jsonList.map((json) => AzkarModel.fromJson(json)).toList();
    } catch (e) {
      print('Error loading Azkar data: $e');
      return [];
    }
  }

  static Future<AzkarModel?> getAzkarByCategory(String category) async {
    final azkarList = await loadAzkar();
    return azkarList.firstWhere(
      (azkar) => azkar.category == category,
      orElse: () => throw Exception('Category not found'),
    );
  }

  static Future<List<String>> getAllCategories() async {
    final azkarList = await loadAzkar();
    return azkarList.map((azkar) => azkar.category).toList();
  }
} 