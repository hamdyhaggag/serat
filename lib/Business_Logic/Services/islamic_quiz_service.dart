import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:serat/data/models/quiz_question.dart';

class IslamicQuizService {
  static const String _questionsPath = 'assets/data/islamic_questions.json';

  static Future<Map<String, dynamic>> getQuestions() async {
    try {
      final String jsonString = await rootBundle.loadString(_questionsPath);
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      return jsonData;
    } catch (e) {
      print('Error loading questions: $e');
      // Return fallback data instead of rethrowing
      return getFallbackData();
    }
  }

  static List<QuizQuestion> parseQuestions(Map<String, dynamic> jsonData) {
    try {
      final List<dynamic> questionsJson = jsonData['questions'];
      return questionsJson.map((json) => QuizQuestion.fromJson(json)).toList();
    } catch (e) {
      print('Error parsing questions: $e');
      return [];
    }
  }

  static String convertDifficultyToEnglish(String arabicDifficulty) {
    switch (arabicDifficulty) {
      case 'سهل':
        return 'easy';
      case 'متوسط':
        return 'medium';
      case 'صعب':
        return 'hard';
      default:
        return arabicDifficulty;
    }
  }

  static String convertCategoryToId(String arabicCategory) {
    switch (arabicCategory) {
      case 'القرآن الكريم':
        return 'quran';
      case 'السنة النبوية':
        return 'hadith';
      case 'العقيدة':
        return 'history';
      case 'الفقه':
        return 'fiqh';
      case 'الأنبياء والرسل':
        return 'prophets';
      case 'الصحابة الكرام':
        return 'companions';
      default:
        return arabicCategory;
    }
  }

  static List<Map<String, dynamic>> getCategories(
      Map<String, dynamic> jsonData) {
    try {
      final List<dynamic> categoriesJson = jsonData['categories'];
      return categoriesJson
          .map((json) => json as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error getting categories: $e');
      return [];
    }
  }

  static Map<String, dynamic> getFallbackData() {
    return {
      'categories': [
        {
          'id': 'quran',
          'name': 'القرآن الكريم',
          'description': 'أسئلة عن القرآن الكريم وتفسيره'
        }
      ],
      'questions': [
        {
          'id': 'quran_1',
          'category': 'quran',
          'difficulty': 'easy',
          'question': 'ما هو أول ما نزل من القرآن الكريم؟',
          'options': [
            'اقرأ باسم ربك الذي خلق',
            'بسم الله الرحمن الرحيم',
            'الحمد لله رب العالمين',
            'قل هو الله أحد'
          ],
          'correctAnswer': 'اقرأ باسم ربك الذي خلق',
          'explanation':
              'نزلت أول آية من سورة العلق على النبي محمد صلى الله عليه وسلم في غار حراء',
          'hint': 'هي أول آية من سورة العلق'
        },
        {
          'id': 'quran_2',
          'category': 'quran',
          'difficulty': 'easy',
          'question': 'كم عدد أركان الإسلام؟',
          'options': ['3', '4', '5', '6'],
          'correctAnswer': '5',
          'explanation':
              'أركان الإسلام خمسة: الشهادتان، الصلاة، الزكاة، الصوم، الحج',
          'hint': 'عددها بين 4 و 6'
        }
      ]
    };
  }

  static List<Map<String, dynamic>> getQuestionsByCategory(
    List<Map<String, dynamic>> questions,
    String category,
  ) {
    return questions.where((q) => q['category'] == category).toList();
  }

  static List<Map<String, dynamic>> getQuestionsByDifficulty(
    List<Map<String, dynamic>> questions,
    String difficulty,
  ) {
    return questions.where((q) => q['difficulty'] == difficulty).toList();
  }

  static List<Map<String, dynamic>> shuffleQuestions(
      List<Map<String, dynamic>> questions) {
    final List<Map<String, dynamic>> shuffled = List.from(questions);
    shuffled.shuffle();
    return shuffled;
  }
}
