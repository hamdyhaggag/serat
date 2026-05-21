import 'package:flutter/material.dart';
import 'package:serat/Presentation/screens/about/widgets/developer_dialog.dart';
import 'package:serat/Presentation/screens/about/about_screen_constants.dart';
import 'package:serat/imports.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:serat/Presentation/screens/about/models/developer_info.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppColors.primaryColor;
    final subtextColor = isDarkMode ? Colors.white60 : Colors.black54;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xff121212) : const Color(0xffF8FAF9),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Premium Header with Backdrop Blur
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            stretch: true,
            backgroundColor: isDarkMode ? const Color(0xff1A2B25) : primaryColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: const AppText(
                'عن تطبيـق صـراط',
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                fontFamily: 'Cairo',
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Abstract Islamic Pattern
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.1,
                      child: Image.asset(
                        'assets/logo.webp', // Using logo as a pattern background
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          isDarkMode ? const Color(0xff121212) : const Color(0xffF8FAF9),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Hero(
                      tag: 'app_logo',
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Image.asset(
                          'assets/logo.webp',
                          height: 70,
                          width: 70,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Info Card
                  _buildGlassCard(
                    isDarkMode,
                    child: Column(
                      children: [
                        const AppText(
                          AboutScreenConstants.appName,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                        const SizedBox(height: 4),
                        AppText(
                          'الإصدار ${AboutScreenConstants.appVersion}',
                          fontSize: 12,
                          color: subtextColor,
                          fontFamily: 'DIN',
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1, thickness: 0.5),
                        ),
                        AppText(
                          AboutScreenConstants.appDescription,
                          fontSize: 13,
                          color: subtextColor,
                          align: TextAlign.center,
                          fontFamily: 'Cairo',
                          height: 1.6,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  _buildSectionLabel('المميزات الرئيسية', isDarkMode),
                  const SizedBox(height: 12),
                  _buildFeaturesGrid(isDarkMode),

                  const SizedBox(height: 24),
                  _buildSectionLabel('المطور', isDarkMode),
                  const SizedBox(height: 12),
                  _buildDeveloperCard(context, AboutScreenConstants.developers.first, isDarkMode),

                  const SizedBox(height: 24),
                  _buildSectionLabel('روابط ومشاركة', isDarkMode),
                  const SizedBox(height: 12),
                  _buildQuickActions(context, isDarkMode),
                  
                  const SizedBox(height: 40),
                  Center(
                    child: AppText(
                      'صنع بكل حب ليخدم المسلمين',
                      fontSize: 11,
                      color: subtextColor.withOpacity(0.5),
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text, bool isDarkMode) {
    return AppText(
      text,
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: AppColors.primaryColor,
      fontFamily: 'Cairo',
    );
  }

  Widget _buildGlassCard(bool isDarkMode, {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xff1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildFeaturesGrid(bool isDarkMode) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: AboutScreenConstants.features.length >= 4 ? 4 : AboutScreenConstants.features.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.6,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final feature = AboutScreenConstants.features[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xff1C1C1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(feature.icon, size: 20, color: AppColors.primaryColor),
              const SizedBox(height: 6),
              AppText(
                feature.title,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'Cairo',
                align: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDeveloperCard(BuildContext context, DeveloperInfo developer, bool isDarkMode) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => DeveloperDialog(
            developerInfo: developer,
            isDarkMode: isDarkMode,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xff1C1C1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person_rounded, size: 24, color: AppColors.primaryColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    developer.name,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                  AppText(
                    developer.role,
                    fontSize: 12,
                    color: isDarkMode ? Colors.white60 : Colors.black54,
                    fontFamily: 'Cairo',
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isDarkMode) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: AboutScreenConstants.actionButtons.map((button) {
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: InkWell(
                  onTap: () => _handleActionButtonTap(context, button),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primaryColor.withOpacity(0.1)),
                    ),
                    child: Column(
                      children: [
                        Icon(button.icon, size: 20, color: AppColors.primaryColor),
                        const SizedBox(height: 6),
                        AppText(
                          button.title,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                          fontFamily: 'Cairo',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      }
    );
  }

  void _launchURL(Uri uri) async {
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint("Could not launch $uri: $e");
    }
  }

  void _handleActionButtonTap(BuildContext context, ActionButton button) async {
    switch (button.type) {
      case ActionButtonType.rate:
        final packageInfo = await PackageInfo.fromPlatform();
        final appId = packageInfo.packageName;
        final uri = Uri.parse(
          Platform.isAndroid
              ? 'market://details?id=$appId'
              : 'https://apps.apple.com/app/idYOUR_IOS_APP_ID',
        );
        _launchURL(uri);
        break;
      case ActionButtonType.share:
        Share.share(AboutScreenConstants.shareMessage);
        break;
      case ActionButtonType.feedback:
        final String email = 'arabianatech@gmail.com';
        final Uri emailUri = Uri(
          scheme: 'mailto',
          path: email,
          query: 'subject=${Uri.encodeComponent('ملاحظات حول تطبيق صراط')}',
        );
        _launchURL(emailUri);
        break;
    }
  }
}
