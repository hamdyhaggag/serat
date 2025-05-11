import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/radio_model.dart';

class RadioService {
  static const String _baseUrl = 'https://mp3quran.net/api/v3/radios';
  static const String _cacheKey = 'cached_radio_stations';

  Future<List<RadioStation>> getRadioStations({String language = 'ar', bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cachedData = await _getCachedStations();
      if (cachedData.isNotEmpty) {
        return cachedData;
      }
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?language=$language'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> stationsJson = data['radios'] as List<dynamic>;

        final stations = stationsJson
            .map((json) => RadioStation.fromJson(json as Map<String, dynamic>))
            .toList();

        // Cache the stations
        await _cacheStations(stations);
        
        return stations;
      } else {
        throw Exception('Failed to load radio stations');
      }
    } catch (e) {
      // If there's an error and we have cached data, return it
      final cachedData = await _getCachedStations();
      if (cachedData.isNotEmpty) {
        return cachedData;
      }
      throw Exception('Error fetching radio stations: $e');
    }
  }

  Future<void> _cacheStations(List<RadioStation> stations) async {
    final prefs = await SharedPreferences.getInstance();
    final stationsJson = stations.map((station) => {
      'id': station.id,
      'name': station.name,
      'url': station.url,
    }).toList();
    await prefs.setString(_cacheKey, json.encode(stationsJson));
  }

  Future<List<RadioStation>> _getCachedStations() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(_cacheKey);
    if (cachedData != null) {
      final List<dynamic> stationsJson = json.decode(cachedData);
      return stationsJson
          .map((json) => RadioStation.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
