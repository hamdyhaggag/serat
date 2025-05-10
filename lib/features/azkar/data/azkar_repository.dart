import 'dart:convert';
import 'package:flutter/services.dart';
import '../domain/azkar_model.dart';

class AzkarRepository {
  Future<List<Azkar>> getMorningAzkar() async {
    final String response =
        await rootBundle.loadString('assets/azkar/morning.json');
    final List<dynamic> data = json.decode(response);
    return data.map((json) => Azkar.fromJson(json)).toList();
  }

  Future<List<Azkar>> getEveningAzkar() async {
    final String response =
        await rootBundle.loadString('assets/azkar/evening.json');
    final List<dynamic> data = json.decode(response);
    return data.map((json) => Azkar.fromJson(json)).toList();
  }

  Future<List<Azkar>> getSleepAzkar() async {
    final String response =
        await rootBundle.loadString('assets/azkar/sleep.json');
    final List<dynamic> data = json.decode(response);
    return data.map((json) => Azkar.fromJson(json)).toList();
  }

  Future<List<Azkar>> getAllAzkar() async {
    final morningAzkar = await getMorningAzkar();
    final eveningAzkar = await getEveningAzkar();
    final sleepAzkar = await getSleepAzkar();

    return [...morningAzkar, ...eveningAzkar, ...sleepAzkar];
  }
}
