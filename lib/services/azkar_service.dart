import 'dart:convert';
import 'package:http/http.dart' as http;
import '../features/azkar/domain/azkar_model.dart';
import 'package:flutter/services.dart' show rootBundle;

class AzkarService {
  static const String _baseUrl =
      'https://raw.githubusercontent.com/ahmed-ali7/azkar-api/main/azkar.json';
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  Future<Map<String, dynamic>> _fetchWithRetry(String url) async {
    int attempts = 0;
    while (attempts < _maxRetries) {
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          return json.decode(response.body) as Map<String, dynamic>;
        }
      } catch (e) {
        attempts++;
        if (attempts == _maxRetries) {
          throw Exception(
              'Failed to fetch data after $_maxRetries attempts: $e');
        }
        await Future.delayed(_retryDelay);
      }
    }
    throw Exception('Failed to fetch data after $_maxRetries attempts');
  }

  Future<List<Azkar>> _loadLocalData(String assetPath) async {
    try {
      final String response = await rootBundle.loadString(assetPath);
      final List<dynamic> data = json.decode(response) as List<dynamic>;
      return data
          .map((json) => Azkar.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading local data: $e');
      rethrow;
    }
  }

  Future<List<Azkar>> fetchAzkar() async {
    try {
      final data = await _fetchWithRetry(_baseUrl);
      final List<dynamic> azkarData = data['azkar'] as List<dynamic>? ?? [];
      return azkarData
          .map((json) => Azkar.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching all azkar: $e');
      return _loadLocalData('assets/azkar/all.json');
    }
  }

  Future<List<Azkar>> fetchMorningAzkar() async {
    try {
      final data = await _fetchWithRetry(_baseUrl);
      final List<dynamic> morningAzkar =
          data['morning'] as List<dynamic>? ?? [];
      return morningAzkar
          .map((json) => Azkar.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching morning azkar: $e');
      return _loadLocalData('assets/azkar/morning.json');
    }
  }

  Future<List<Azkar>> fetchEveningAzkar() async {
    try {
      final data = await _fetchWithRetry(_baseUrl);
      final List<dynamic> eveningAzkar =
          data['evening'] as List<dynamic>? ?? [];
      return eveningAzkar
          .map((json) => Azkar.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching evening azkar: $e');
      return _loadLocalData('assets/azkar/evening.json');
    }
  }

  Future<List<Azkar>> fetchSleepAzkar() async {
    try {
      final data = await _fetchWithRetry(_baseUrl);
      final List<dynamic> sleepAzkar = data['sleep'] as List<dynamic>? ?? [];
      return sleepAzkar
          .map((json) => Azkar.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching sleep azkar: $e');
      return _loadLocalData('assets/azkar/sleep.json');
    }
  }
}
