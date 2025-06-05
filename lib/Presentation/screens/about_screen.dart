import 'package:flutter/material.dart';
import 'package:serat/imports.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:serat/Presentation/Widgets/Shared/custom_app_bar.dart';
import 'dart:math' show pi, cos, sin;

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xff1F1F1F) : Colors.white,
      appBar: const CustomAppBar(title: 'حول التطبيق'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 15),
                    decoration: BoxDecoration(
                      color: isDarkMode ? AppColors.primaryColor : Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromRGBO(0, 0, 0, 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: const Color.fromRGBO(0, 0, 0, 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Background pattern
                        Positioned.fill(
                          child: CustomPaint(
                            painter: ModernPatternPainter(
                              color: isDarkMode
                                  ? const Color.fromRGBO(255, 255, 255, 0.03)
                                  : const Color.fromRGBO(0, 0, 0, 0.02),
                            ),
                          ),
                        ),
                        // Shimmer effect
                        Positioned.fill(
                          child: ShimmerEffect(
                            isDarkMode: isDarkMode,
                          ),
                        ),
                        // Content
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 25, vertical: 15),
                          child: Row(
                            children: [
                              Hero(
                                tag: 'app_logo',
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isDarkMode
                                        ? const Color.fromRGBO(
                                            255, 255, 255, 0.1)
                                        : Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            const Color.fromRGBO(0, 0, 0, 0.2),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                      BoxShadow(
                                        color:
                                            const Color.fromRGBO(0, 0, 0, 0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Image.asset(
                                    'assets/logo.png',
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ShaderMask(
                                      shaderCallback: (bounds) =>
                                          LinearGradient(
                                        colors: isDarkMode
                                            ? [
                                                Colors.white,
                                                const Color.fromRGBO(
                                                    255, 255, 255, 0.9),
                                              ]
                                            : [
                                                AppColors.primaryColor,
                                                const Color.fromRGBO(
                                                    0, 0, 0, 0.8),
                                              ],
                                      ).createShader(bounds),
                                      child: const AppText(
                                        'تطبيق صراط',
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDarkMode
                                            ? const Color.fromRGBO(
                                                255, 255, 255, 0.1)
                                            : const Color.fromRGBO(
                                                0, 0, 0, 0.05),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isDarkMode
                                              ? const Color.fromRGBO(
                                                  255, 255, 255, 0.1)
                                              : const Color.fromRGBO(
                                                  0, 0, 0, 0.1),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.verified,
                                            size: 14,
                                            color: isDarkMode
                                                ? const Color.fromRGBO(
                                                    255, 255, 255, 0.7)
                                                : const Color.fromRGBO(
                                                    0, 0, 0, 0.7),
                                          ),
                                          const SizedBox(width: 6),
                                          AppText(
                                            'الإصدار 1.0.0',
                                            fontSize: 14,
                                            color: isDarkMode
                                                ? const Color.fromRGBO(
                                                    255, 255, 255, 0.7)
                                                : const Color.fromRGBO(
                                                    0, 0, 0, 0.7),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _buildFeatureSection(
                  'المميزات الرئيسية',
                  [
                    _buildFeatureItem(
                      'مواقيت الصلاة',
                      'تحديد مواقيت الصلاة بدقة حسب موقعك',
                      Icons.access_time,
                      isDarkMode,
                    ),
                    _buildFeatureItem(
                      'اتجاه القبلة',
                      'تحديد اتجاه القبلة باستخدام البوصلة',
                      Icons.explore,
                      isDarkMode,
                    ),
                    _buildFeatureItem(
                      'القرآن الكريم',
                      'القرآن الكريم مع التفسير والقراء',
                      Icons.menu_book,
                      isDarkMode,
                    ),
                    _buildFeatureItem(
                      'بطاقات القرآن',
                      'تصفح القرآن الكريم بطريقة سهلة',
                      Icons.book,
                      isDarkMode,
                    ),
                    _buildFeatureItem(
                      'القراء',
                      'استماع للقراء المشهورين',
                      Icons.record_voice_over,
                      isDarkMode,
                    ),
                    _buildFeatureItem(
                      'الراديو الإسلامي',
                      'استماع للراديو الإسلامي المباشر',
                      Icons.radio,
                      isDarkMode,
                    ),
                    _buildFeatureItem(
                      'روائع القصص',
                      'قصص إسلامية هادفة',
                      Icons.auto_stories,
                      isDarkMode,
                    ),
                    _buildFeatureItem(
                      'حاسبة الزكاة',
                      'حساب الزكاة بسهولة',
                      Icons.calculate,
                      isDarkMode,
                    ),
                    _buildFeatureItem(
                      'الأذكار',
                      'أذكار الصباح والمساء مع التنبيهات',
                      Icons.book,
                      isDarkMode,
                    ),
                    _buildFeatureItem(
                      'الأحاديث النبوية',
                      'كتب الأحاديث النبوية الشريفة',
                      Icons.menu_book_rounded,
                      isDarkMode,
                    ),
                  ],
                  isDarkMode),
              const SizedBox(height: 30),
              _buildActionButtons(isDarkMode),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeveloperDialog(BuildContext context, bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color:
                isDarkMode ? const Color.fromRGBO(40, 40, 40, 1) : Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? const Color.fromRGBO(255, 255, 255, 0.05)
                      : const Color.fromRGBO(0, 0, 0, 0.02),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  size: 40,
                  color: isDarkMode
                      ? const Color.fromRGBO(255, 255, 255, 0.9)
                      : const Color.fromRGBO(0, 0, 0, 0.9),
                ),
              ),
              const SizedBox(height: 20),
              AppText(
                'حمدي حجاج',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDarkMode
                    ? const Color.fromRGBO(255, 255, 255, 0.9)
                    : const Color.fromRGBO(0, 0, 0, 0.9),
              ),
              const SizedBox(height: 8),
              AppText(
                'مطور تطبيقات Flutter',
                fontSize: 16,
                color: isDarkMode
                    ? const Color.fromRGBO(255, 255, 255, 0.7)
                    : const Color.fromRGBO(0, 0, 0, 0.7),
              ),
              const SizedBox(height: 20),
              _buildContactButton(
                'GitHub',
                Icons.code,
                'https://github.com/serat',
                isDarkMode,
              ),
              const SizedBox(height: 12),
              _buildContactButton(
                'LinkedIn',
                Icons.work,
                'https://linkedin.com/in/serat',
                isDarkMode,
              ),
              const SizedBox(height: 12),
              _buildContactButton(
                'Facebook',
                Icons.facebook,
                'https://facebook.com/serat',
                isDarkMode,
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: AppText(
                  'إغلاق',
                  fontSize: 16,
                  color: isDarkMode
                      ? const Color.fromRGBO(255, 255, 255, 0.7)
                      : const Color.fromRGBO(0, 0, 0, 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactButton(
    String title,
    IconData icon,
    String url,
    bool isDarkMode,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => launchUrl(Uri.parse(url)),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: isDarkMode
                ? const Color.fromRGBO(255, 255, 255, 0.05)
                : const Color.fromRGBO(0, 0, 0, 0.02),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode
                  ? const Color.fromRGBO(255, 255, 255, 0.1)
                  : const Color.fromRGBO(0, 0, 0, 0.05),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isDarkMode
                    ? const Color.fromRGBO(255, 255, 255, 0.7)
                    : const Color.fromRGBO(0, 0, 0, 0.7),
              ),
              const SizedBox(width: 12),
              AppText(
                title,
                fontSize: 16,
                color: isDarkMode
                    ? const Color.fromRGBO(255, 255, 255, 0.7)
                    : const Color.fromRGBO(0, 0, 0, 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureSection(
    String title,
    List<Widget> features,
    bool isDarkMode,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          title,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.white : AppColors.primaryColor,
        ),
        const SizedBox(height: 15),
        ...features,
      ],
    );
  }

  Widget _buildFeatureItem(
    String title,
    String description,
    IconData icon,
    bool isDarkMode,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryColor, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : AppColors.primaryColor,
                ),
                const SizedBox(height: 4),
                AppText(
                  description,
                  fontSize: 14,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: _buildActionButton(
              'تقييم التطبيق',
              Icons.star,
              () => launchUrl(
                Uri.parse(
                  'https://play.google.com/store/apps/details?id=com.serat.app',
                ),
              ),
              isDarkMode,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildActionButton(
              'مشاركة التطبيق',
              Icons.share,
              () => Share.share(
                'تطبيق صراط هو تطبيق إسلامي شامل يحتوي على العديد من المميزات مثل:\n\n'
                '• مواقيت الصلاة\n'
                '• اتجاه القبلة\n'
                '• الأذكار الصباحية والمسائية\n'
                '• الأربعين النووية\n'
                '• السبحة الإلكترونية\n'
                '• القرآن الكريم مع التفسير\n'
                '• القراء المشهورين\n'
                '• الراديو الإسلامي\n'
                '• فيديوهات القرآن الكريم\n'
                '• التقويم الهجري\n'
                '• حاسبة الزكاة\n'
                '• الهدف اليومي\n'
                '• التنبيهات والإشعارات\n'
                '• الوضع الليلي\n'
                '• دعم اللغة العربية\n\n'
                'تحميل التطبيق من هنا:\n'
                'https://play.google.com/store/apps/details?id=com.serat.app',
              ),
              isDarkMode,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildActionButton(
              'تطوير التطبيق',
              Icons.code,
              () => _showDeveloperDialog(context, isDarkMode),
              isDarkMode,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String title,
    IconData icon,
    VoidCallback onTap,
    bool isDarkMode,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[800] : Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.primaryColor, size: 24),
              const SizedBox(height: 8),
              AppText(
                title,
                fontSize: 12,
                color: isDarkMode ? Colors.white : AppColors.primaryColor,
                align: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ModernPatternPainter extends CustomPainter {
  final Color color;

  ModernPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw hexagon pattern
    final hexSize = size.width / 8;
    for (int i = -2; i < 10; i++) {
      for (int j = -2; j < 6; j++) {
        final centerX = i * hexSize * 1.5;
        final centerY = j * hexSize * 1.732 + (i % 2) * hexSize * 0.866;

        _drawHexagon(canvas, Offset(centerX, centerY), hexSize * 0.8, paint);
      }
    }

    // Draw subtle dots
    paint.style = PaintingStyle.fill;
    for (int i = 0; i < 30; i++) {
      final x = size.width * (i + 1) / 31;
      final y = size.height * 0.2;
      canvas.drawCircle(Offset(x, y), 1, paint);
    }
  }

  void _drawHexagon(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = i * pi / 3;
      final x = center.dx + size * cos(angle);
      final y = center.dy + size * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ShimmerEffect extends StatefulWidget {
  final bool isDarkMode;

  const ShimmerEffect({
    Key? key,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.isDarkMode
                    ? const Color.fromRGBO(255, 255, 255, 0.0)
                    : const Color.fromRGBO(0, 0, 0, 0.0),
                widget.isDarkMode
                    ? const Color.fromRGBO(255, 255, 255, 0.05)
                    : const Color.fromRGBO(0, 0, 0, 0.05),
                widget.isDarkMode
                    ? const Color.fromRGBO(255, 255, 255, 0.0)
                    : const Color.fromRGBO(0, 0, 0, 0.0),
              ],
              stops: [
                0.0,
                _animation.value,
                1.0,
              ],
            ).createShader(bounds);
          },
          child: Container(
            color: Colors.transparent,
          ),
        );
      },
    );
  }
}
