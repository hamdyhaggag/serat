import 'dart:convert';
import 'package:flutter/services.dart';
import '../Model/history_model.dart';

class HistoryService {
  static Future<List<HistoryModel>> getHistory() async {
    try {
      final String response =
          await rootBundle.loadString('assets/data/history.json');
      final List<dynamic> data = json.decode(response);
      return data.map((json) => HistoryModel.fromJson(json)).toList();
    } catch (e) {
      print('Error loading history data: $e');
      return [];
    }
  }
}
