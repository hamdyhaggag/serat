import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:serat/features/adhkar/models/adhkar_category.dart';

class AdhkarService {
  Future<List<AdhkarCategory>> getAdhkarCategories() async {
    final String response =
        await rootBundle.loadString('assets/data/adhkar.json');
    final data = await json.decode(response) as List;
    return data.map((item) => AdhkarCategory.fromJson(item)).toList();
  }
}
