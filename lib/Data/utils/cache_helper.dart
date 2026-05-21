import 'dart:convert';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';

import '../Model/times_model.dart';
import '../Model/calendar_model.dart';

class CacheHelper {
  static SharedPreferences? sharedPreferences;

  static init() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  //===============================================================

  static saveData({
    required String key,
    required dynamic value,
  }) async {
    log("saving >>> $value into local >>> with key $key");

    if (value is String) {
      sharedPreferences!.setString(key, value);
    }
    if (value is int) {
      sharedPreferences!.setInt(key, value);
    }
    if (value is double) {
      sharedPreferences!.setDouble(key, value);
    }
    if (value is bool) {
      sharedPreferences!.setBool(key, value);
    }
  }

  //===============================================================

  static String getString({required String key}) {
    return sharedPreferences!.getString(key) ?? "";
  }

  static int getInteger({required String key}) {
    return sharedPreferences!.getInt(key) ?? 0;
  }

  static bool getBoolean({required String key}) {
    return sharedPreferences!.getBool(key) ?? false;
  }

  static double getDouble({required String key}) {
    return sharedPreferences!.getDouble(key) ?? 0.0;
  }

  static dynamic getData({
    required String key,
  }) {
    return sharedPreferences?.get(key);
  }

  static Future<bool> putData({
    required String key,
    required dynamic value,
  }) async {
    if (value is String) return await sharedPreferences!.setString(key, value);
    if (value is int) return await sharedPreferences!.setInt(key, value);
    if (value is bool) return await sharedPreferences!.setBool(key, value);
    if (value is double) return await sharedPreferences!.setDouble(key, value);
    return false;
  }

  static Future<bool> removeData({required String key}) async {
    return await sharedPreferences!.remove(key);
  }
}

void saveTimeModel({
  required TimesModel timeModel,
}) async {
  await CacheHelper.saveData(
    key: 'TimesModel',
    value: json.encode(timeModel.toJson()),
  );
}

Future<TimesModel?> getTimeModel() async {
  final now = DateTime.now();
  final todayDateStr =
      "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}";

  // 1. Try to get today's specific TimesModel first
  final timeModelJson = CacheHelper.getString(key: 'TimesModel');
  if (timeModelJson.isNotEmpty) {
    final model = TimesModel.fromJson(jsonDecode(timeModelJson));
    // If it's for today, return it
    if (model.data.date.gregorian.date == todayDateStr) {
      return model;
    }
  }

  // 2. If not found or outdated, try to extract today's data from CalendarModel
  final calendarModel = await getCalendarModel();
  if (calendarModel != null) {
    try {
      final todayData = calendarModel.data.firstWhere(
        (element) => element.date.gregorian.date == todayDateStr,
      );
      return TimesModel(
        code: calendarModel.code,
        status: calendarModel.status,
        data: todayData,
      );
    } catch (_) {
      // If not found in calendar, fallback to whatever we have in TimesModel
    }
  }

  // 3. Last fallback
  if (timeModelJson.isNotEmpty) {
    return TimesModel.fromJson(jsonDecode(timeModelJson));
  }

  return null;
}

void saveCalendarModel({
  required CalendarModel calendarModel,
}) async {
  await CacheHelper.saveData(
    key: 'CalendarModel',
    value: json.encode(calendarModel.toJson()),
  );
}

Future<CalendarModel?> getCalendarModel() async {
  final calendarModel = CacheHelper.getString(key: 'CalendarModel');
  if (calendarModel.isNotEmpty) {
    return CalendarModel.fromJson(jsonDecode(calendarModel));
  } else {
    return null;
  }
}
