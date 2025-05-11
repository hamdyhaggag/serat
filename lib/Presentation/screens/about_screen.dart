import 'package:flutter/material.dart';
import 'package:serat/imports.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:serat/Presentation/Widgets/Shared/custom_app_bar.dart';

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
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors:
                            isDarkMode
                                ? [Colors.grey[800]!, Colors.black]
                                : [
                                  AppColors.primaryColor.withOpacity(0.1),
                                  Colors.white,
                                ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Hero(
                          tag: 'app_logo',
                          child: Image.asset(
                            'assets/logo.png',
                            width: 120,
                            height: 120,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 20),
                        AppText(
                          'تطبيق صراط',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color:
                              isDarkMode
                                  ? Colors.white
                                  : AppColors.primaryColor,
                        ),
                        const SizedBox(height: 5),
                        AppText(
                          'الإصدار 1.0.0',
                          fontSize: 16,
                          color:
                              isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _buildFeatureSection('المميزات الرئيسية', [
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
                  'الأذكار',
                  'أذكار الصباح والمساء مع التنبيهات',
                  Icons.book,
                  isDarkMode,
                ),
                _buildFeatureItem(
                  'القرآن الكريم',
                  'القرآن الكريم مع التفسير والقراء',
                  Icons.menu_book,
                  isDarkMode,
                ),
                _buildFeatureItem(
                  'الراديو الإسلامي',
                  'استماع للراديو الإسلامي المباشر',
                  Icons.radio,
                  isDarkMode,
                ),
                _buildFeatureItem(
                  'التقويم الهجري',
                  'التقويم الهجري مع المناسبات',
                  Icons.calendar_month,
                  isDarkMode,
                ),
              ], isDarkMode),
              const SizedBox(height: 30),
              _buildActionButtons(isDarkMode),
              const SizedBox(height: 20),
              AppText(
                'تم تطوير التطبيق بواسطة حمدي حجاج',
                fontSize: 14,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                align: TextAlign.center,
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
            color: Colors.black.withOpacity(0.05),
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
              color: AppColors.primaryColor.withOpacity(0.1),
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
              () => launchUrl(Uri.parse('https://github.com/serat')),
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
