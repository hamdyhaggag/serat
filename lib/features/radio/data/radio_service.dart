import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/radio_model.dart';

class RadioService {
  static const String _baseUrl = 'https://mp3quran.net/api/v3/radios';

  Future<List<RadioStation>> getRadioStations({String language = 'ar'}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?language=$language'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> stationsJson = data['radios'] as List<dynamic>;

        return stationsJson
            .map((json) => RadioStation.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load radio stations');
      }
    } catch (e) {
      throw Exception('Error fetching radio stations: $e');
    }
  }
}
