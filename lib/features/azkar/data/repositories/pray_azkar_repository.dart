import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/pray_azkar_model.dart';

class PrayAzkarRepository {
  Future<PrayAzkarData> getPrayAzkar() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/azkar/pray_azkar.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      return PrayAzkarData.fromJson(jsonData);
    } catch (e) {
      throw Exception('Failed to load pray azkar: $e');
    }
  }
}
