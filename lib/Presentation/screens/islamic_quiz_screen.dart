import 'package:flutter/material.dart';
import 'dart:async';
import 'package:serat/Business_Logic/Services/islamic_quiz_service.dart';
import 'package:serat/Business_Logic/Models/quiz_progress.dart';
import 'package:serat/Presentation/screens/quiz_completion_screen.dart';
import 'package:serat/data/models/quiz_question.dart';
import 'package:serat/Presentation/theme/app_theme.dart';

class IslamicQuizScreen extends StatefulWidget {
  const IslamicQuizScreen({Key? key}) : super(key: key);

  @override
  _IslamicQuizScreenState createState() => _IslamicQuizScreenState();
}

class _IslamicQuizScreenState extends State<IslamicQuizScreen>
    with SingleTickerProviderStateMixin {
  List<QuizQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  bool _isLoading = true;
  String? _selectedAnswer;
  bool _showHint = false;
  int _hintsRemaining = 3;
  Timer? _questionTimer;
  int _timeElapsed = 0;
  List<Map<String, dynamic>> _questionResults = [];
  String _selectedCategory = 'القرآن الكريم';
  String _selectedDifficulty = 'سهل';
  Map<String, dynamic>? _jsonData;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _loadQuizData();
  }

  @override
  void dispose() {
    _questionTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadQuizData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      print('Loading quiz data...');
      _jsonData = await IslamicQuizService.getQuestions();
      print('Raw JSON data loaded: ${_jsonData != null}');
      print('JSON data keys: ${_jsonData?.keys.toList()}');

      final allQuestions = IslamicQuizService.parseQuestions(_jsonData!);
      print('Questions parsed successfully: ${allQuestions.isNotEmpty}');
      print('Total questions loaded: ${allQuestions.length}');
      print('Selected category: $_selectedCategory');
      print('Selected difficulty: $_selectedDifficulty');
      print(
          'Converted category: ${IslamicQuizService.convertCategoryToId(_selectedCategory)}');
      print(
          'Converted difficulty: ${IslamicQuizService.convertDifficultyToEnglish(_selectedDifficulty)}');

      _questions = allQuestions.where((q) {
        bool categoryMatch = _selectedCategory == 'all' ||
            q.category ==
                IslamicQuizService.convertCategoryToId(_selectedCategory);
        bool difficultyMatch = _selectedDifficulty == 'all' ||
            q.difficulty ==
                IslamicQuizService.convertDifficultyToEnglish(
                    _selectedDifficulty);
        print(
            'Question ${q.id}: category=${q.category}, difficulty=${q.difficulty}, matches=${categoryMatch && difficultyMatch}');
        return categoryMatch && difficultyMatch;
      }).toList();

      print('Filtered questions count: ${_questions.length}');
      print(
          'First question data: ${_questions.isNotEmpty ? _questions.first.toJson() : "No questions"}');

      if (_questions.isEmpty) {
        print('WARNING: No questions available after filtering!');
      }

      _questions.shuffle();

      setState(() {
        _isLoading = false;
        _currentQuestionIndex = 0;
        _selectedAnswer = null;
        _showHint = false;
        _hintsRemaining = 3;
        _timeElapsed = 0;
        _questionResults = [];
      });

      _startTimer();
      _animationController.forward();
    } catch (e) {
      print('Error loading quiz data: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ في تحميل الأسئلة'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _startTimer() {
    _questionTimer?.cancel();
    _timeElapsed = 0;
    _questionTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _timeElapsed++;
      });
    });
  }

  void _stopTimer() {
    _questionTimer?.cancel();
  }

  void _selectAnswer(String answer) {
    if (_selectedAnswer != null) return;

    _stopTimer();
    setState(() {
      _selectedAnswer = answer;
    });

    final currentQuestion = _questions[_currentQuestionIndex];
    final isCorrect = answer == currentQuestion.correctAnswer;

    _questionResults.add({
      'question': currentQuestion.question,
      'selectedAnswer': answer,
      'correctAnswer': currentQuestion.correctAnswer,
      'isCorrect': isCorrect,
      'timeSpent': _timeElapsed,
      'hintUsed': _showHint,
    });

    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        if (_currentQuestionIndex < _questions.length - 1) {
          _animationController.reset();
          setState(() {
            _currentQuestionIndex++;
            _selectedAnswer = null;
            _showHint = false;
            _timeElapsed = 0;
          });
          _startTimer();
          _animationController.forward();
        } else {
          _showCompletionScreen();
        }
      }
    });
  }

  void _showCompletionScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuizCompletionScreen(
          results: _questionResults,
          totalQuestions: _questions.length,
        ),
      ),
    );
  }

  void _useHint() {
    if (_hintsRemaining > 0 && !_showHint) {
      setState(() {
        _showHint = true;
        _hintsRemaining--;
      });
    }
  }

  void _changeCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _loadQuizData();
  }

  void _changeDifficulty(String difficulty) {
    setState(() {
      _selectedDifficulty = difficulty;
    });
    _loadQuizData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final isLargeScreen = size.width > 600;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'اختبار إسلامي',
            style: TextStyle(
              fontFamily: 'DIN',
              fontSize: isSmallScreen ? 18 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: Color(0xff137058),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Color(0xff137058),
              ),
              SizedBox(height: 16),
              Text(
                'جاري تحميل الأسئلة...',
                style: TextStyle(
                  fontFamily: 'DIN',
                  fontSize: isSmallScreen ? 14 : 16,
                  color: colorScheme.onBackground,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'اختبار إسلامي',
            style: TextStyle(
              fontFamily: 'DIN',
              fontSize: isSmallScreen ? 18 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: Color(0xff137058),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline,
                  size: isSmallScreen ? 40 : 48, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'لا توجد أسئلة متاحة',
                style: TextStyle(
                  fontFamily: 'DIN',
                  fontSize: isSmallScreen ? 16 : 18,
                  color: colorScheme.onBackground,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'اختبار إسلامي',
          style: TextStyle(
            fontFamily: 'DIN',
            fontSize: isSmallScreen ? 18 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xff137058),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            color: Color(0xff137058),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 12 : 16,
                        vertical: isSmallScreen ? 8 : 12,
                      ),
                    ),
                    items: [
                      DropdownMenuItem<String>(
                        value: 'القرآن الكريم',
                        child: Text(
                          'القرآن الكريم',
                          style: TextStyle(
                            fontFamily: 'DIN',
                            fontSize: isSmallScreen ? 14 : 16,
                          ),
                        ),
                      ),
                      DropdownMenuItem<String>(
                        value: 'السنة النبوية',
                        child: Text(
                          'السنة النبوية',
                          style: TextStyle(
                            fontFamily: 'DIN',
                            fontSize: isSmallScreen ? 14 : 16,
                          ),
                        ),
                      ),
                      DropdownMenuItem<String>(
                        value: 'العقيدة',
                        child: Text(
                          'العقيدة',
                          style: TextStyle(
                            fontFamily: 'DIN',
                            fontSize: isSmallScreen ? 14 : 16,
                          ),
                        ),
                      ),
                      DropdownMenuItem<String>(
                        value: 'الفقه',
                        child: Text(
                          'الفقه',
                          style: TextStyle(
                            fontFamily: 'DIN',
                            fontSize: isSmallScreen ? 14 : 16,
                          ),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedCategory = value;
                        });
                        _loadQuizData();
                      }
                    },
                    dropdownColor: Colors.white,
                    style: TextStyle(
                      fontFamily: 'DIN',
                      fontSize: isSmallScreen ? 14 : 16,
                      color: Colors.black87,
                    ),
                    icon: Icon(Icons.arrow_drop_down, color: Color(0xff137058)),
                  ),
                ),
                SizedBox(width: isSmallScreen ? 6 : 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedDifficulty,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 12 : 16,
                        vertical: isSmallScreen ? 8 : 12,
                      ),
                    ),
                    items: [
                      DropdownMenuItem<String>(
                        value: 'سهل',
                        child: Text(
                          'سهل',
                          style: TextStyle(
                            fontFamily: 'DIN',
                            fontSize: isSmallScreen ? 14 : 16,
                          ),
                        ),
                      ),
                      DropdownMenuItem<String>(
                        value: 'متوسط',
                        child: Text(
                          'متوسط',
                          style: TextStyle(
                            fontFamily: 'DIN',
                            fontSize: isSmallScreen ? 14 : 16,
                          ),
                        ),
                      ),
                      DropdownMenuItem<String>(
                        value: 'صعب',
                        child: Text(
                          'صعب',
                          style: TextStyle(
                            fontFamily: 'DIN',
                            fontSize: isSmallScreen ? 14 : 16,
                          ),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedDifficulty = value;
                        });
                        _loadQuizData();
                      }
                    },
                    dropdownColor: Colors.white,
                    style: TextStyle(
                      fontFamily: 'DIN',
                      fontSize: isSmallScreen ? 14 : 16,
                      color: Colors.black87,
                    ),
                    icon: Icon(Icons.arrow_drop_down, color: Color(0xff137058)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                          child: Column(
                            children: [
                              Text(
                                'السؤال ${_currentQuestionIndex + 1} من ${_questions.length}',
                                style: TextStyle(
                                  fontFamily: 'DIN',
                                  fontSize: isSmallScreen ? 14 : 16,
                                  color: Color(0xff137058),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: isSmallScreen ? 12 : 16),
                              Text(
                                currentQuestion.question,
                                style: TextStyle(
                                  fontFamily: 'DIN',
                                  fontSize: isSmallScreen
                                      ? 18
                                      : isLargeScreen
                                          ? 24
                                          : 20,
                                  color: Color(0xff137058),
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_showHint)
                        Container(
                          margin: EdgeInsets.symmetric(
                              vertical: isSmallScreen ? 12 : 16),
                          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                          decoration: BoxDecoration(
                            color: AppTheme.warningLight.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.warningLight.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                color: AppTheme.warningLight,
                                size: isSmallScreen ? 20 : 24,
                              ),
                              SizedBox(width: isSmallScreen ? 6 : 8),
                              Expanded(
                                child: Text(
                                  'تلميح: ${currentQuestion.hint}',
                                  style: TextStyle(
                                    fontFamily: 'DIN',
                                    fontSize: isSmallScreen ? 14 : 16,
                                    color: AppTheme.warningLight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      SizedBox(height: isSmallScreen ? 12 : 16),
                      ...currentQuestion.options.map((option) {
                        final isSelected = _selectedAnswer == option;
                        final isCorrect =
                            option == currentQuestion.correctAnswer;

                        Color backgroundColor =
                            Color(0xff137058).withOpacity(0.1);
                        Color borderColor = Color(0xff137058);
                        Color textColor = Color(0xff137058);

                        if (_selectedAnswer != null) {
                          if (isSelected) {
                            backgroundColor = isCorrect
                                ? AppTheme.successLight.withOpacity(0.1)
                                : AppTheme.errorLight.withOpacity(0.1);
                            borderColor = isCorrect
                                ? AppTheme.successLight
                                : AppTheme.errorLight;
                            textColor = borderColor;
                          } else if (isCorrect) {
                            backgroundColor =
                                AppTheme.successLight.withOpacity(0.1);
                            borderColor = AppTheme.successLight;
                            textColor = borderColor;
                          }
                        }

                        return Container(
                          margin:
                              EdgeInsets.only(bottom: isSmallScreen ? 8 : 12),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _selectAnswer(option),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding:
                                    EdgeInsets.all(isSmallScreen ? 12 : 16),
                                decoration: BoxDecoration(
                                  color: backgroundColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: borderColor),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 5,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: isSmallScreen ? 20 : 24,
                                      height: isSmallScreen ? 20 : 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: borderColor),
                                        color: isSelected
                                            ? borderColor
                                            : Colors.transparent,
                                      ),
                                      child: isSelected
                                          ? Icon(
                                              isCorrect
                                                  ? Icons.check
                                                  : Icons.close,
                                              size: isSmallScreen ? 14 : 16,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                    SizedBox(width: isSmallScreen ? 8 : 12),
                                    Expanded(
                                      child: Text(
                                        option,
                                        style: TextStyle(
                                          fontFamily: 'DIN',
                                          fontSize: isSmallScreen ? 14 : 16,
                                          color: textColor,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            decoration: BoxDecoration(
              color: Color(0xff137058),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: AppTheme.warningLight,
                      size: isSmallScreen ? 20 : 24,
                    ),
                    SizedBox(width: isSmallScreen ? 6 : 8),
                    Text(
                      'التلميحات المتبقية: $_hintsRemaining',
                      style: TextStyle(
                        fontFamily: 'DIN',
                        fontSize: isSmallScreen ? 14 : 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _hintsRemaining > 0 ? _useHint : null,
                  icon: Icon(
                    Icons.lightbulb_outline,
                    size: isSmallScreen ? 20 : 24,
                  ),
                  label: Text(
                    'استخدم تلميحاً',
                    style: TextStyle(
                      fontFamily: 'DIN',
                      fontSize: isSmallScreen ? 14 : 16,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff137058).withOpacity(0.1),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 12 : 16,
                      vertical: isSmallScreen ? 8 : 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
