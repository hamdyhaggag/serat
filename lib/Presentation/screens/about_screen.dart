import 'package:flutter/material.dart';
import 'package:serat/imports.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:serat/Presentation/Widgets/Shared/custom_app_bar.dart';
import 'package:serat/Presentation/constants/about_screen_constants.dart';
import 'package:serat/Presentation/widgets/about/feature_item_widget.dart';
import 'package:serat/Presentation/widgets/about/action_button_widget.dart';
import 'package:serat/Presentation/widgets/about/developer_dialog.dart';
import 'package:serat/Presentation/widgets/about/modern_pattern_painter.dart';
import 'package:serat/Presentation/widgets/about/shimmer_effect.dart';

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
              _buildAppInfoCard(isDarkMode),
              const SizedBox(height: 30),
              _buildFeatureSection(isDarkMode),
              const SizedBox(height: 30),
              _buildActionButtons(isDarkMode),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppInfoCard(bool isDarkMode) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
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
              Positioned.fill(
                child: CustomPaint(
                  painter: ModernPatternPainter(
                    color: isDarkMode
                        ? const Color.fromRGBO(255, 255, 255, 0.03)
                        : const Color.fromRGBO(0, 0, 0, 0.02),
                  ),
                ),
              ),
              Positioned.fill(
                child: ShimmerEffect(isDarkMode: isDarkMode),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                child: Row(
                  children: [
                    Hero(
                      tag: 'app_logo',
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? const Color.fromRGBO(255, 255, 255, 0.1)
                              : Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromRGBO(0, 0, 0, 0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                            BoxShadow(
                              color: const Color.fromRGBO(0, 0, 0, 0.1),
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
                            shaderCallback: (bounds) => LinearGradient(
                              colors: isDarkMode
                                  ? [
                                      Colors.white,
                                      const Color.fromRGBO(255, 255, 255, 0.9),
                                    ]
                                  : [
                                      AppColors.primaryColor,
                                      const Color.fromRGBO(0, 0, 0, 0.8),
                                    ],
                            ).createShader(bounds),
                            child: AppText(
                              AboutScreenConstants.appName,
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
                                  ? const Color.fromRGBO(255, 255, 255, 0.1)
                                  : const Color.fromRGBO(0, 0, 0, 0.05),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isDarkMode
                                    ? const Color.fromRGBO(255, 255, 255, 0.1)
                                    : const Color.fromRGBO(0, 0, 0, 0.1),
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
                                      ? const Color.fromRGBO(255, 255, 255, 0.7)
                                      : const Color.fromRGBO(0, 0, 0, 0.7),
                                ),
                                const SizedBox(width: 6),
                                AppText(
                                  AboutScreenConstants.appVersion,
                                  fontSize: 14,
                                  color: isDarkMode
                                      ? const Color.fromRGBO(255, 255, 255, 0.7)
                                      : const Color.fromRGBO(0, 0, 0, 0.7),
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
    );
  }

  Widget _buildFeatureSection(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          AboutScreenConstants.mainFeaturesTitle,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.white : AppColors.primaryColor,
        ),
        const SizedBox(height: 15),
        ...AboutScreenConstants.features.map(
          (feature) => FeatureItemWidget(
            feature: feature,
            isDarkMode: isDarkMode,
          ),
        ),
      ],
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
            child: ActionButtonWidget(
              title: AboutScreenConstants.rateAppText,
              icon: Icons.star,
              onTap: () => launchUrl(
                Uri.parse(
                  'https://play.google.com/store/apps/details?id=com.serat.app',
                ),
              ),
              isDarkMode: isDarkMode,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ActionButtonWidget(
              title: AboutScreenConstants.shareAppText,
              icon: Icons.share,
              onTap: () => Share.share(AboutScreenConstants.shareMessage),
              isDarkMode: isDarkMode,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ActionButtonWidget(
              title: AboutScreenConstants.developerText,
              icon: Icons.code,
              onTap: () => _showDeveloperDialog(context, isDarkMode),
              isDarkMode: isDarkMode,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeveloperDialog(BuildContext context, bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) => DeveloperDialog(
        developerInfo: AboutScreenConstants.developerInfo,
        isDarkMode: isDarkMode,
      ),
    );
  }
}
