import 'package:flutter/material.dart';
import 'package:serat/Presentation/screens/islamic_quiz_screen.dart';
import 'package:serat/Presentation/theme/app_theme.dart';
// import 'package:flutter_animate/flutter_animate.dart';

class QuizCompletionScreen extends StatelessWidget {
  final List<Map<String, dynamic>> results;
  final int totalQuestions;

  const QuizCompletionScreen({
    Key? key,
    required this.results,
    required this.totalQuestions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    final correctAnswers = results.where((r) => r['isCorrect'] as bool).length;
    final accuracy = totalQuestions > 0
        ? (correctAnswers / totalQuestions * 100).round()
        : 0;
    final averageTime = results.isEmpty
        ? 0
        : results.fold<int>(
              0,
              (sum, result) => sum + (result['timeSpent'] as int),
            ) /
            results.length;
    final hintsUsed = results.where((r) => r['hintUsed'] as bool).length;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'نتيجة الاختبار',
          style: TextStyle(
            fontFamily: 'DIN',
            fontSize: isSmallScreen ? 18 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDarkMode ? Colors.white : Colors.white,
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section with Score
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                    24,
                    MediaQuery.of(context).padding.top + kToolbarHeight + 20,
                    24,
                    40),
                decoration: BoxDecoration(
                    color: (isDarkMode ? Colors.black : const Color(0xff137058))
                        .withOpacity(0.9),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isDarkMode
                                ? Colors.black
                                : const Color(0xff137058))
                            .withOpacity(0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      )
                    ]),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 150,
                          height: 150,
                          child: CircularProgressIndicator(
                            value: accuracy / 100,
                            strokeWidth: 10,
                            backgroundColor: Colors.white.withOpacity(0.1),
                            color: AppTheme.warningLight,
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              '$accuracy%',
                              style: TextStyle(
                                fontFamily: 'DIN',
                                fontSize: isSmallScreen ? 36 : 48,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'النتيجة',
                              style: TextStyle(
                                fontFamily: 'DIN',
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      accuracy >= 80
                          ? 'ممتاز!'
                          : accuracy >= 50
                              ? 'جيد جداً!'
                              : 'حاول مرة أخرى',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: isSmallScreen ? 24 : 28,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'لقد أجبت على $correctAnswers من أصل $totalQuestions أسئلة بشكل صحيح',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'DIN',
                        fontSize: isSmallScreen ? 14 : 16,
                        color: Colors.white.withOpacity(0.8),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                child: Column(
                  children: [
                    // Stats Grid
                    Row(
                      children: [
                        Expanded(
                            child: _buildStatCard(
                                context,
                                'الوقت المستغرق',
                                '${averageTime.round()} ث',
                                Icons.timer_outlined,
                                const Color(0xff137058),
                                isDarkMode)),
                        const SizedBox(width: 16),
                        Expanded(
                            child: _buildStatCard(
                                context,
                                'التلميحات',
                                '$hintsUsed',
                                Icons.lightbulb_outline,
                                AppTheme.warningLight,
                                isDarkMode)),
                      ],
                    ),

                    SizedBox(height: isSmallScreen ? 24 : 32),

                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'مراجعة الأسئلة',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: isSmallScreen ? 18 : 20,
                          color: isDarkMode ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 12 : 16),

                    ...results.asMap().entries.map((entry) {
                      final index = entry.key;
                      final result = entry.value;
                      return _buildQuestionResultCard(
                          context, index + 1, result, isDarkMode);
                    }).toList(),
                  ],
                ),
              ),
              const SizedBox(height: 80), // Specs for floating button
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
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
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor:
                      isDarkMode ? Colors.white : const Color(0xff137058),
                  side: BorderSide(
                      color: isDarkMode
                          ? Colors.white54
                          : const Color(0xff137058)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('الخروج',
                    style: TextStyle(
                        fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const IslamicQuizScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryLight,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('اختبار جديد',
                    style: TextStyle(
                        fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value,
      IconData icon, Color color, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color:
                  isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ]),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
                fontFamily: 'DIN',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
                fontFamily: 'DIN',
                fontSize: 14,
                color: isDarkMode ? Colors.white70 : Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionResultCard(
    BuildContext context,
    int questionNumber,
    Map<String, dynamic> result,
    bool isDarkMode,
  ) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final isCorrect = result['isCorrect'] as bool;

    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
          color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isCorrect
                  ? AppTheme.successLight.withOpacity(0.5)
                  : AppTheme.errorLight.withOpacity(0.5),
              width: 1),
          boxShadow: [
            BoxShadow(
                color: (isCorrect ? AppTheme.successLight : AppTheme.errorLight)
                    .withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 4))
          ]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCorrect
                    ? AppTheme.successLight.withOpacity(0.1)
                    : AppTheme.errorLight.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  isCorrect ? Icons.check : Icons.close,
                  size: 20,
                  color:
                      isCorrect ? AppTheme.successLight : AppTheme.errorLight,
                ),
              ),
            ),
            title: Text(
              'السؤال $questionNumber',
              style: TextStyle(
                fontFamily: 'Cairo', // Premium font
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            subtitle: Text(
              isCorrect ? 'إجابة صحيحة' : 'إجابة خاطئة',
              style: TextStyle(
                fontFamily: 'DIN',
                fontSize: 14,
                color: isCorrect ? AppTheme.successLight : AppTheme.errorLight,
              ),
            ),
            childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              Divider(color: isDarkMode ? Colors.white10 : Colors.black12),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  result['question'] as String,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: (isCorrect
                            ? AppTheme.successLight
                            : AppTheme.errorLight)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: (isCorrect
                                ? AppTheme.successLight
                                : AppTheme.errorLight)
                            .withOpacity(0.3))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إجابتك',
                      style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'DIN',
                          color: isCorrect
                              ? AppTheme.successLight
                              : AppTheme.errorLight),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      result['selectedAnswer'] as String,
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87),
                    ),
                  ],
                ),
              ),
              if (!isCorrect) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: AppTheme.successLight.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppTheme.successLight.withOpacity(0.3))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'الإجابة الصحيحة',
                        style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'DIN',
                            color: AppTheme.successLight),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        result['correctAnswer'] as String,
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87),
                      ),
                    ],
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
