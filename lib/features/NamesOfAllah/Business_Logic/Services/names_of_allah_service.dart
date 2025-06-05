import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:serat/Features/NamesOfAllah/Data/Model/names_of_allah_model.dart';

class NamesOfAllahService {
  static Future<List<NamesOfAllahModel>> loadNamesOfAllah() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/Names_Of_Allah.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => NamesOfAllahModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  static NamesOfAllahModel? getRandomName(List<NamesOfAllahModel> names) {
    if (names.isEmpty) return null;
    names.shuffle();
    return names.first;
  }
}
