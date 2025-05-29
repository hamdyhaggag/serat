import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/hijri_calendar_model.dart';

class HijriCalendarService {
  static const String baseUrl = 'https://api.aladhan.com/v1';

  Future<HijriCalendarResponse> getHijriCalendar(int month, int year) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/hToGCalendar/$month/$year'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        // Validate response structure
        if (jsonResponse == null) {
          throw Exception('Empty response from server');
        }

        if (jsonResponse['code'] == null ||
            jsonResponse['status'] == null ||
            jsonResponse['data'] == null) {
          throw Exception('Invalid response format: missing required fields');
        }

        if (jsonResponse['data'] is! List) {
          throw Exception('Invalid response format: data is not a list');
        }

        return HijriCalendarResponse.fromJson(jsonResponse);
      } else {
        throw Exception(
            'Failed to load Hijri calendar data: ${response.statusCode}');
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Invalid response format: ${e.message}');
      } else if (e is TypeError) {
        throw Exception('Type error while parsing response: ${e.toString()}');
      } else {
        throw Exception('Error fetching Hijri calendar data: $e');
      }
    }
  }
}
