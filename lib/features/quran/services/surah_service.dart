import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/surah_model.dart';

class SurahService {
  Future<List<SurahModel>> loadSurahs() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/cards.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => SurahModel.fromJson(json)).toList();
    } catch (e) {
      print('Error loading surahs: $e');
      return [];
    }
  }
}
