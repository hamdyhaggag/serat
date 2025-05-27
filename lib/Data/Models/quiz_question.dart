class QuizQuestion {
  final String id;
  final String category;
  final String difficulty;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final String hint;

  QuizQuestion({
    required this.id,
    required this.category,
    required this.difficulty,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.hint,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as String,
      category: json['category'] as String,
      difficulty: json['difficulty'] as String,
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      correctAnswer: json['correctAnswer'] as String,
      explanation: json['explanation'] as String,
      hint: json['hint'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'difficulty': difficulty,
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'hint': hint,
    };
  }
} 