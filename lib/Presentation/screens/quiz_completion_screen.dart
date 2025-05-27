import 'package:flutter/material.dart';
import 'package:serat/Business_Logic/Services/islamic_quiz_service.dart';
import 'package:serat/Presentation/screens/islamic_quiz_screen.dart';
import 'package:serat/Presentation/theme/app_theme.dart';

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
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final isLargeScreen = size.width > 600;

    final correctAnswers = results.where((r) => r['isCorrect'] as bool).length;
    final accuracy = (correctAnswers / totalQuestions * 100).round();
    final averageTime = results.fold<int>(
          0,
          (sum, result) => sum + (result['timeSpent'] as int),
        ) /
        results.length;
    final hintsUsed = results.where((r) => r['hintUsed'] as bool).length;

    return Scaffold(
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
        backgroundColor: const Color(0xff137058),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
              decoration: const BoxDecoration(
                color: Color(0xff137058),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: isSmallScreen ? 100 : 120,
                    height: isSmallScreen ? 100 : 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$accuracy%',
                        style: TextStyle(
                          fontFamily: 'DIN',
                          fontSize: isSmallScreen ? 32 : 40,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 16),
                  Text(
                    'ممتاز!',
                    style: TextStyle(
                      fontFamily: 'DIN',
                      fontSize: isSmallScreen ? 20 : 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 6 : 8),
                  Text(
                    'لقد أكملت الاختبار بنجاح',
                    style: TextStyle(
                      fontFamily: 'DIN',
                      fontSize: isSmallScreen ? 14 : 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              child: Column(
                children: [
                  _buildStatsCard(
                    context,
                    [
                      _buildStatItem(
                        context,
                        'الإجابات الصحيحة',
                        '$correctAnswers من $totalQuestions',
                        Icons.check_circle_outline,
                        AppTheme.successLight,
                      ),
                      _buildStatItem(
                        context,
                        'متوسط الوقت',
                        '${averageTime.round()} ثانية',
                        Icons.timer_outlined,
                        const Color(0xff137058),
                      ),
                      _buildStatItem(
                        context,
                        'التلميحات المستخدمة',
                        '$hintsUsed تلميحات',
                        Icons.lightbulb_outline,
                        AppTheme.warningLight,
                      ),
                    ],
                  ),
                  SizedBox(height: isSmallScreen ? 20 : 24),
                  Text(
                    'تفاصيل الأسئلة',
                    style: TextStyle(
                      fontFamily: 'DIN',
                      fontSize: isSmallScreen ? 18 : 20,
                      color: colorScheme.onBackground,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 16),
                  ...results.asMap().entries.map((entry) {
                    final index = entry.key;
                    final result = entry.value;
                    return _buildQuestionResultCard(context, index + 1, result);
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'العودة للرئيسية',
                  style: TextStyle(
                    fontFamily: 'DIN',
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff137058),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: isSmallScreen ? 12 : 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            SizedBox(width: isSmallScreen ? 8 : 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Pop all screens until we reach the quiz screen
                  Navigator.popUntil(context, (route) => route.isFirst);
                  // Push a new quiz screen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const IslamicQuizScreen(),
                    ),
                  );
                },
                child: Text(
                  'اختبار جديد',
                  style: TextStyle(
                    fontFamily: 'DIN',
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xff137058),
                  padding: EdgeInsets.symmetric(
                    vertical: isSmallScreen ? 12 : 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xff137058)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, List<Widget> items) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          children: items.map((item) {
            final isLast = items.last == item;
            return Column(
              children: [
                item,
                if (!isLast)
                  Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: isSmallScreen ? 8 : 12),
                    child: Divider(
                      color: colorScheme.onSurface.withOpacity(0.1),
                    ),
                  ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: isSmallScreen ? 20 : 24,
          ),
        ),
        SizedBox(width: isSmallScreen ? 12 : 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'DIN',
                  fontSize: isSmallScreen ? 12 : 14,
                  color: color.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'DIN',
                  fontSize: isSmallScreen ? 16 : 18,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionResultCard(
    BuildContext context,
    int questionNumber,
    Map<String, dynamic> result,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final isCorrect = result['isCorrect'] as bool;

    return Card(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 8 : 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCorrect
              ? AppTheme.successLight.withOpacity(0.3)
              : AppTheme.errorLight.withOpacity(0.3),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: isSmallScreen ? 28 : 32,
                  height: isSmallScreen ? 28 : 32,
                  decoration: BoxDecoration(
                    color: isCorrect
                        ? AppTheme.successLight.withOpacity(0.1)
                        : AppTheme.errorLight.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      isCorrect ? Icons.check : Icons.close,
                      size: isSmallScreen ? 16 : 20,
                      color: isCorrect
                          ? AppTheme.successLight
                          : AppTheme.errorLight,
                    ),
                  ),
                ),
                SizedBox(width: isSmallScreen ? 8 : 12),
                Expanded(
                  child: Text(
                    'السؤال $questionNumber',
                    style: TextStyle(
                      fontFamily: 'DIN',
                      fontSize: isSmallScreen ? 16 : 18,
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 8 : 12,
                    vertical: isSmallScreen ? 4 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: isCorrect
                        ? AppTheme.successLight.withOpacity(0.1)
                        : AppTheme.errorLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${result['timeSpent']} ثانية',
                    style: TextStyle(
                      fontFamily: 'DIN',
                      fontSize: isSmallScreen ? 12 : 14,
                      color: isCorrect
                          ? AppTheme.successLight
                          : AppTheme.errorLight,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isSmallScreen ? 8 : 12),
            Text(
              result['question'] as String,
              style: TextStyle(
                fontFamily: 'DIN',
                fontSize: isSmallScreen ? 14 : 16,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: isSmallScreen ? 8 : 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إجابتك:',
                        style: TextStyle(
                          fontFamily: 'DIN',
                          fontSize: isSmallScreen ? 12 : 14,
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        result['selectedAnswer'] as String,
                        style: TextStyle(
                          fontFamily: 'DIN',
                          fontSize: isSmallScreen ? 14 : 16,
                          color: isCorrect
                              ? AppTheme.successLight
                              : AppTheme.errorLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isCorrect)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الإجابة الصحيحة:',
                          style: TextStyle(
                            fontFamily: 'DIN',
                            fontSize: isSmallScreen ? 12 : 14,
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          result['correctAnswer'] as String,
                          style: TextStyle(
                            fontFamily: 'DIN',
                            fontSize: isSmallScreen ? 14 : 16,
                            color: AppTheme.successLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            if (result['hintUsed'] as bool)
              Padding(
                padding: EdgeInsets.only(top: isSmallScreen ? 8 : 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: isSmallScreen ? 14 : 16,
                      color: AppTheme.warningLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'تم استخدام تلميح',
                      style: TextStyle(
                        fontFamily: 'DIN',
                        fontSize: isSmallScreen ? 12 : 14,
                        color: AppTheme.warningLight,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
