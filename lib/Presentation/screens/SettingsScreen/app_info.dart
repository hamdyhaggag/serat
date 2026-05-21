import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class AppInfo extends StatelessWidget {
  const AppInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDarkMode ? const Color(0xff4CAF93) : AppColors.primaryColor;

    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xff121212) : const Color(0xffF8FAF9),
      appBar: AppBar(
        title: const AppText(
          'عن التطبيق',
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: 'Cairo',
        ),
        centerTitle: true,
        backgroundColor: isDarkMode ? const Color(0xff1A2B25) : AppColors.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // App Logo & Header Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDarkMode
                      ? [const Color(0xff1A2B25), const Color(0xff121212)]
                      : [primaryColor, primaryColor.withValues(alpha: 0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(15),
                    child: Image.asset(
                      'assets/logo.webp', // Updated from logo.png to logo.webp
                      errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.auto_awesome_rounded,
                          color: primaryColor,
                          size: 40),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const AppText(
                    'صراط - Serat',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Cairo',
                  ),
                  const SizedBox(height: 8),
                  AppText(
                    'الإصدار 1.2.0',
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8),
                    fontFamily: 'Cairo',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Main Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText(
                    'حول المشروع',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                  const SizedBox(height: 12),
                  AppText(
                    'تطبيق صراط هو مبادرة تهدف إلى تيسير العبادات اليومية للمسلم من خلال واجهة عصرية وسهلة الاستخدام. يجمع التطبيق بين الدقة في المواعيد والجمال في التصميم ليكون رفيقك الدائم في رحلتك الروحية.',
                    fontSize: 13,
                    height: 24, // Fix overlapping by providing pixel height (24/13 ≈ 1.85 multiplier)
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                    fontFamily: 'Cairo',
                    maxLines: 10,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Key Features Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText(
                    'المميزات الرئيسية',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(
                    context,
                    icon: Icons.timer_rounded,
                    title: 'مواقيت دقيقة',
                    desc: 'تنبيهات دقيقة لكل صلاة بناءً على موقعك.',
                    isDarkMode: isDarkMode,
                    primaryColor: primaryColor,
                  ),
                  _buildFeatureItem(
                    context,
                    icon: Icons.menu_book_rounded,
                    title: 'القرآن الكريم',
                    desc: 'قراءة واستماع مع تجربة بصرية مريحة.',
                    isDarkMode: isDarkMode,
                    primaryColor: primaryColor,
                  ),
                  _buildFeatureItem(
                    context,
                    icon: Icons.auto_awesome_rounded,
                    title: 'الأذكار والأدعية',
                    desc: 'مجموعة شاملة من الأذكار اليومية والأدعية المأثورة.',
                    isDarkMode: isDarkMode,
                    primaryColor: primaryColor,
                  ),
                  _buildFeatureItem(
                    context,
                    icon: Icons.explore_rounded,
                    title: 'اتجاه القبلة',
                    desc: 'تحديد دقيق لاتجاه القبلة من أي مكان في العالم.',
                    isDarkMode: isDarkMode,
                    primaryColor: primaryColor,
                  ),
                  _buildFeatureItem(
                    context,
                    icon: Icons.touch_app_rounded,
                    title: 'السبحة الإلكترونية',
                    desc: 'عداد تسبيح ذكي يساعدك على ذكر الله في كل وقت.',
                    isDarkMode: isDarkMode,
                    primaryColor: primaryColor,
                  ),
                  _buildFeatureItem(
                    context,
                    icon: Icons.timeline_rounded,
                    title: 'اليوم النبوي',
                    desc: 'رحلة بصرية داخل الروتين اليومي للنبي ﷺ.',
                    isDarkMode: isDarkMode,
                    primaryColor: primaryColor,
                  ),
                  _buildFeatureItem(
                    context,
                    icon: Icons.stars_rounded,
                    title: 'أسماء الله الحسنى',
                    desc: 'تعرف على معاني أسماء الله الحسنى وآثارها الإيمانية.',
                    isDarkMode: isDarkMode,
                    primaryColor: primaryColor,
                  ),
                  _buildFeatureItem(
                    context,
                    icon: Icons.auto_graph_rounded,
                    title: 'مركز العبادات',
                    desc: 'تتبع مجهودك الأسبوعي وتطوير عاداتك.',
                    isDarkMode: isDarkMode,
                    primaryColor: primaryColor,
                  ),
                  _buildFeatureItem(
                    context,
                    icon: Icons.radio_rounded,
                    title: 'الراديو الإسلامي',
                    desc: 'بث مباشر لأهم المحطات الإذاعية.',
                    isDarkMode: isDarkMode,
                    primaryColor: primaryColor,
                  ),
                  _buildFeatureItem(
                    context,
                    icon: Icons.history_edu_rounded,
                    title: 'قصص الأنبياء',
                    desc: 'قصص وعبر من حياة الأنبياء والرسل عليهم السلام.',
                    isDarkMode: isDarkMode,
                    primaryColor: primaryColor,
                  ),
                   _buildFeatureItem(
                    context,
                    icon: Icons.format_list_bulleted_rounded,
                    title: 'الأحاديث النبوية',
                    desc: 'مجموعة مختارة من الأحاديث الصحيحة.',
                    isDarkMode: isDarkMode,
                    primaryColor: primaryColor,
                  ),
                   _buildFeatureItem(
                    context,
                    icon: Icons.quiz_rounded,
                    title: 'مسابقات إسلامية',
                    desc: 'اختبر معلوماتك الدينية بطريقة ممتعة.',
                    isDarkMode: isDarkMode,
                    primaryColor: primaryColor,
                  ),
                   _buildFeatureItem(
                    context,
                    icon: Icons.calculate_rounded,
                    title: 'حاسبة الزكاة',
                    desc: 'طريقة سهلة ودقيقة لحساب زكاتك.',
                    isDarkMode: isDarkMode,
                    primaryColor: primaryColor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Developer Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText(
                    'المطور',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xff1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.person_rounded, size: 24, color: primaryColor),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AppText(
                                'حمدي حجاج',
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Cairo',
                              ),
                              AppText(
                                'مطور التطبيق',
                                fontSize: 12,
                                color: isDarkMode ? Colors.white60 : Colors.grey[600],
                                fontFamily: 'Cairo',
                              ),
                            ],
                          ),
                        ),
                        // Social Links
                        Row(
                          children: [
                            _buildSocialButton(
                              icon: FontAwesomeIcons.github,
                              onTap: () => launchUrl(Uri.parse('https://github.com/hamdyhaggag')),
                              isDarkMode: isDarkMode,
                              primaryColor: primaryColor,
                            ),
                            const SizedBox(width: 8),
                            _buildSocialButton(
                              icon: FontAwesomeIcons.linkedin,
                              onTap: () => launchUrl(Uri.parse('https://linkedin.com/in/hamdyhaggag74')),
                              isDarkMode: isDarkMode,
                              primaryColor: primaryColor,
                            ),
                            const SizedBox(width: 8),
                            _buildSocialButton(
                              icon: Icons.alternate_email_rounded,
                              onTap: () => launchUrl(Uri.parse('mailto:hamdyhaggag74@gmail.com')),
                              isDarkMode: isDarkMode,
                              primaryColor: primaryColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Footer
            AppText(
              'صنع بكل حب ليخدم الأمة الإسلامية',
              fontSize: 11,
              color: Colors.grey[500],
              fontFamily: 'Cairo',
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String desc,
    required bool isDarkMode,
    required Color primaryColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xff1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: primaryColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
                const SizedBox(height: 4),
                AppText(
                  desc,
                  fontSize: 12,
                  color: isDarkMode ? Colors.white60 : Colors.grey[600],
                  fontFamily: 'Cairo',
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildSocialButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDarkMode,
    required Color primaryColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: primaryColor, size: 18),
      ),
    );
  }
}
