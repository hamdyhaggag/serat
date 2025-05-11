import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/sleep_azkar_model.dart';

class SleepAzkarRepository {
  Future<SleepAzkarData> getSleepAzkar() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/azkar/sleep_azkar.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      return SleepAzkarData.fromJson(jsonData);
    } catch (e) {
      throw Exception('Failed to load sleep azkar: $e');
    }
  }
}
