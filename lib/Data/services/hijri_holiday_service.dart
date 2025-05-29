import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:serat/Data/Model/hijri_holiday_model.dart';

class HijriHolidayService {
  final String baseUrl = 'http://api.aladhan.com/v1';

  Future<HijriHolidayModel> getHijriHolidays(int day, int month) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/hijriHolidays/$day/$month'),
      );

      if (response.statusCode == 200) {
        return HijriHolidayModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load holidays');
      }
    } catch (e) {
      throw Exception('Error fetching holidays: $e');
    }
  }
}
