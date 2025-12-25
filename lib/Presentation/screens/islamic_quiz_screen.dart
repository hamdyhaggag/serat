import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:serat/Business_Logic/Services/islamic_quiz_service.dart';
import 'package:serat/Business_Logic/Models/quiz_progress.dart';
import 'package:serat/Presentation/screens/quiz_completion_screen.dart';
import 'package:serat/data/models/quiz_question.dart';
import 'package:serat/Presentation/theme/app_theme.dart';
// import 'package:flutter_animate/flutter_animate.dart'; // Ensure this is available

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
  Map<String, dynamic>? _jsonData;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
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

      _jsonData = await IslamicQuizService.getQuestions();

      final allQuestions = IslamicQuizService.parseQuestions(_jsonData!);

      // Shuffle all questions and take a subset
      allQuestions.shuffle();
      _questions = allQuestions.take(10).toList(); // Take 10 random questions

      if (_questions.isEmpty) {
        debugPrint('WARNING: No questions available!');
      }

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
      debugPrint('Error loading quiz data: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
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
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _timeElapsed++;
        });
      }
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

    Future.delayed(const Duration(seconds: 2), () {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final isLargeScreen = size.width > 600;
    final isDarkMode = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text(
            'اختبار إسلامي',
            style: TextStyle(fontFamily: 'DIN', fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDarkMode
                  ? [const Color(0xff121212), const Color(0xff1E1E1E)]
                  : [const Color(0xffF8F9FA), const Color(0xffE8F5E9)],
            ),
          ),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text(
            'اختبار إسلامي',
            style: TextStyle(fontFamily: 'DIN', fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDarkMode
                  ? [const Color(0xff121212), const Color(0xff1E1E1E)]
                  : [const Color(0xffF8F9FA), const Color(0xffE8F5E9)],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline,
                    size: isSmallScreen ? 40 : 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'لا توجد أسئلة متاحة',
                  style: TextStyle(
                    fontFamily: 'DIN',
                    fontSize: isSmallScreen ? 16 : 18,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      extendBodyBehindAppBar: true,
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: (isDarkMode ? Colors.black : const Color(0xff137058))
                  .withOpacity(0.8),
            ),
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [const Color(0xff121212), const Color(0xff1E1E1E)]
                : [const Color(0xffF8F9FA), const Color(0xffE8F5E9)],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  isSmallScreen ? 12 : 16,
                  MediaQuery.of(context).padding.top + kToolbarHeight + 16,
                  isSmallScreen ? 12 : 16,
                  isSmallScreen ? 12 : 16,
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Glassmorphic Question Card
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? Colors.white.withOpacity(0.05)
                                : Colors.white.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDarkMode
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.white.withOpacity(0.5),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter:
                                  ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Padding(
                                padding:
                                    EdgeInsets.all(isSmallScreen ? 16 : 24),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                          color: AppTheme.primaryLight
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Text(
                                        'السؤال ${_currentQuestionIndex + 1} / ${_questions.length}',
                                        style: TextStyle(
                                          fontFamily: 'DIN',
                                          fontSize: isSmallScreen ? 14 : 16,
                                          color: AppTheme.primaryLight,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: isSmallScreen ? 16 : 24),
                                    Text(
                                      currentQuestion.question,
                                      style: TextStyle(
                                        fontFamily: 'Cairo', // Premium font
                                        height: 1.4,
                                        fontSize: isSmallScreen
                                            ? 18
                                            : isLargeScreen
                                                ? 24
                                                : 20,
                                        color: isDarkMode
                                            ? Colors.white
                                            : const Color(0xff137058),
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
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
                              borderRadius: BorderRadius.circular(16),
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
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black87,
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

                          Color backgroundColor = isDarkMode
                              ? Colors.white.withOpacity(0.05)
                              : Colors.white;
                          Color borderColor = isDarkMode
                              ? Colors.white.withOpacity(0.1)
                              : Colors.transparent;
                          Color textColor =
                              isDarkMode ? Colors.white : Colors.black87;

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
                            margin: EdgeInsets.only(
                                bottom: isSmallScreen ? 10 : 16),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4))
                                ]),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _selectAnswer(option),
                                borderRadius: BorderRadius.circular(16),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  padding:
                                      EdgeInsets.all(isSmallScreen ? 16 : 20),
                                  decoration: BoxDecoration(
                                    color: backgroundColor,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                        color: isSelected
                                            ? borderColor
                                            : Colors.transparent,
                                        width: 1.5),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: isSelected
                                                  ? borderColor
                                                  : (isDarkMode
                                                      ? Colors.white54
                                                      : Colors.black26),
                                              width: 1.5),
                                          color: isSelected
                                              ? borderColor
                                              : Colors.transparent,
                                        ),
                                        child: isSelected
                                            ? Icon(
                                                isCorrect
                                                    ? Icons.check
                                                    : Icons.close,
                                                size: 16,
                                                color: Colors.white,
                                              )
                                            : null,
                                      ),
                                      SizedBox(width: isSmallScreen ? 12 : 16),
                                      Expanded(
                                        child: Text(
                                          option,
                                          style: TextStyle(
                                            fontFamily:
                                                'Cairo', // Consistent font
                                            fontSize: isSmallScreen ? 15 : 17,
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

            // Bottom Bar
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xff1E1E1E) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
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
                          '$_hintsRemaining',
                          style: TextStyle(
                            fontFamily: 'DIN',
                            fontSize: isSmallScreen ? 18 : 20,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
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
                        'تلميح',
                        style: TextStyle(
                          fontFamily: 'DIN',
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryLight,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 20 : 24,
                          vertical: isSmallScreen ? 10 : 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
