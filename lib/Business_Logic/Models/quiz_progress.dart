import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class QuizProgress {
  final String category;
  final String difficulty;
  final int totalQuestions;
  final int correctAnswers;
  final int timeSpent;
  final DateTime date;
  final List<QuestionResult> questionResults;

  QuizProgress({
    required this.category,
    required this.difficulty,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.timeSpent,
    required this.date,
    required this.questionResults,
  });

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'difficulty': difficulty,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'timeSpent': timeSpent,
      'date': date.toIso8601String(),
      'questionResults': questionResults.map((r) => r.toJson()).toList(),
    };
  }

  factory QuizProgress.fromJson(Map<String, dynamic> json) {
    return QuizProgress(
      category: json['category'],
      difficulty: json['difficulty'],
      totalQuestions: json['totalQuestions'],
      correctAnswers: json['correctAnswers'],
      timeSpent: json['timeSpent'],
      date: DateTime.parse(json['date']),
      questionResults: (json['questionResults'] as List)
          .map((r) => QuestionResult.fromJson(r))
          .toList(),
    );
  }

  static Future<void> saveProgress(QuizProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    final progressList = prefs.getStringList('quiz_progress') ?? [];
    progressList.add(jsonEncode(progress.toJson()));
    await prefs.setStringList('quiz_progress', progressList);
  }

  static Future<List<QuizProgress>> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final progressList = prefs.getStringList('quiz_progress') ?? [];
    return progressList
        .map((json) => QuizProgress.fromJson(jsonDecode(json)))
        .toList();
  }

  static Future<void> clearProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('quiz_progress');
  }
}

class QuestionResult {
  final String questionId;
  final bool isCorrect;
  final int timeSpent;
  final String? selectedAnswer;
  final String correctAnswer;

  QuestionResult({
    required this.questionId,
    required this.isCorrect,
    required this.timeSpent,
    this.selectedAnswer,
    required this.correctAnswer,
  });

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'isCorrect': isCorrect,
      'timeSpent': timeSpent,
      'selectedAnswer': selectedAnswer,
      'correctAnswer': correctAnswer,
    };
  }

  factory QuestionResult.fromJson(Map<String, dynamic> json) {
    return QuestionResult(
      questionId: json['questionId'],
      isCorrect: json['isCorrect'],
      timeSpent: json['timeSpent'],
      selectedAnswer: json['selectedAnswer'],
      correctAnswer: json['correctAnswer'],
    );
  }
}
