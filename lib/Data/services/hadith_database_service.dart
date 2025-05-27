import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:serat/domain/models/hadith_model.dart';

class HadithDatabaseService {
  static const Map<String, String> _bookFiles = {
    'الأربعين النووية': 'assets/hadiths/nawawi40.json',
    'صحيح البخاري': 'assets/hadiths/bukhari.json',
    'صحيح مسلم': 'assets/hadiths/muslim.json',
    'سنن أبي داود': 'assets/hadiths/abudawud.json',
    'سنن الترمذي': 'assets/hadiths/tirmidhi.json',
    'سنن النسائي': 'assets/hadiths/nasai.json',
    'سنن ابن ماجه': 'assets/hadiths/ibnmajah.json',
  };

  static const Map<String, String> _bookIds = {
    'الأربعين النووية': 'nawawi',
    'صحيح البخاري': 'bukhari',
    'صحيح مسلم': 'muslim',
    'سنن أبي داود': 'abudawud',
    'سنن الترمذي': 'tirmidhi',
    'سنن النسائي': 'nasai',
    'سنن ابن ماجه': 'ibnmajah',
  };

  Future<List<HadithModel>> getHadiths(String bookName) async {
    try {
      final String filePath = _bookFiles[bookName]!;
      final String jsonString = await rootBundle.loadString(filePath);
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      final List<dynamic> hadithsData = jsonData['hadiths'] ?? [];
      final List<dynamic> chaptersData = jsonData['chapters'] ?? [];

      // Create a map of chapter IDs to their data for easier lookup
      final Map<String, Map<String, dynamic>> chaptersMap = {};
      for (var chapter in chaptersData) {
        if (chapter is Map<String, dynamic>) {
          final id = chapter['id']?.toString();
          if (id != null) {
            chaptersMap[id] = chapter;
          }
        }
      }

      return hadithsData.map((hadith) {
        final english = hadith['english'] as Map<String, dynamic>?;
        final chapterId = hadith['chapterId']?.toString();
        
        // Get chapter data from chapters map
        String chapterName;
        if (chapterId != null && chaptersMap.containsKey(chapterId)) {
          final chapter = chaptersMap[chapterId]!;
          chapterName = chapter['arabic'] as String? ?? 'كتاب $chapterId';
        } else {
          chapterName = 'كتاب ${chapterId ?? ''}';
        }
        
        return HadithModel(
          id: hadith['id'] ?? 0,
          hadithNumber: 'حديث ${hadith['number'] ?? ''}',
          hadithText: hadith['arabic'] ?? '',
          explanation: hadith['explanation'] ?? '',
          narrator: hadith['narrator'] ?? '',
          chapterName: chapterName,
          bookId: _bookIds[bookName] ?? 'unknown',
        );
      }).toList();
    } catch (e) {
      print('Error loading hadiths: $e');
      rethrow;
    }
  }

  Future<HadithModel> getRandomHadith(String bookName) async {
    try {
      final hadiths = await getHadiths(bookName);
      if (hadiths.isEmpty) {
        throw Exception('No hadiths found in the book');
      }

      final random = DateTime.now().millisecondsSinceEpoch % hadiths.length;
      return hadiths[random];
    } catch (e) {
      print('Error getting random hadith: $e');
      rethrow;
    }
  }

  Future<List<Map<String, String>>> getBooks() async {
    try {
      return _bookFiles.entries.map((entry) {
        return {
          'name': entry.key,
          'id': _bookIds[entry.key] ?? 'unknown',
        };
      }).toList();
    } catch (e) {
      print('Error getting books: $e');
      rethrow;
    }
  }
}
