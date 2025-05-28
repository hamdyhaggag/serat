import 'package:flutter/material.dart';
import '../screens/surah_list_screen.dart';

class QuranRoutes {
  static const String surahList = '/quran/surahs';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      surahList: (context) => const SurahListScreen(),
    };
  }
} 