import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/morning_azkar.dart';

class MorningAzkarService {
  static Future<List<MorningAzkar>> loadMorningAzkar() async {
    try {
      final String response =
          await rootBundle.loadString('assets/data/adhkar.json');
      final List<dynamic> data = json.decode(response);
      // Find the morning category
      final morningCategory = data.firstWhere(
          (cat) => cat['category'] == 'أذكار الصباح',
          orElse: () => null);
      if (morningCategory == null) return [];
      final List<dynamic> azkarList = morningCategory['array'] ?? [];
      return azkarList
          .map((json) => MorningAzkar.fromJson({
                'title': json['text'],
                'maxValue': json['count'],
                'initialCounterValue': 0,
                'headtitle': '',
              }))
          .toList();
    } catch (e) {
      print('Error loading morning azkar: $e');
      rethrow;
    }
  }
}
