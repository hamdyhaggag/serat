import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/morning_azkar.dart';

class MorningAzkarService {
  static Future<List<MorningAzkar>> loadMorningAzkar() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/azkar/morning.json',
      );
      final List<dynamic> data = json.decode(response);
      return data.map((json) => MorningAzkar.fromJson(json)).toList();
    } catch (e) {
      print('Error loading morning azkar: $e');
      rethrow;
    }
  }
}
