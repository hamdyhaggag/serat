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
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: const CustomAppBar(title: 'عن التطبيق'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // App Logo
              Center(
                child: CircleAvatar(
                  radius: 44,
                  backgroundColor: isDarkMode
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.05),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      'assets/logo.png',
                      fit: BoxFit.contain,
                      height: 64,
                      width: 64,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              _buildAppInfoCard(isDarkMode),
              const SizedBox(height: 30),
              _buildSectionHeader('المميزات', isDarkMode),
              const SizedBox(height: 10),
              _buildFeaturesHorizontalList(isDarkMode, size),
              const SizedBox(height: 30),
              _buildSectionHeader('المطور', isDarkMode),
              const SizedBox(height: 10),
              _buildDeveloperCardModern(
                  context, AboutScreenConstants.developers.first, isDarkMode),
              const SizedBox(height: 30),
              _buildSectionHeader('روابط سريعة', isDarkMode),
              const SizedBox(height: 10),
              _buildActionButtonsRow(context, isDarkMode),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppInfoCard(bool isDarkMode) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color:
          isDarkMode ? const Color.fromRGBO(255, 255, 255, 0.05) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
        child: Column(
          children: [
            AppText(
              AboutScreenConstants.appName,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDarkMode
                  ? const Color.fromRGBO(255, 255, 255, 0.9)
                  : Colors.black87,
              align: TextAlign.center,
            ),
            const SizedBox(height: 8),
            AppText(
              AboutScreenConstants.appVersion,
              fontSize: 16,
              color: isDarkMode
                  ? const Color.fromRGBO(255, 255, 255, 0.7)
                  : Colors.black54,
              align: TextAlign.center,
            ),
            const SizedBox(height: 16),
            AppText(
              AboutScreenConstants.appDescription,
              fontSize: 16,
              color: isDarkMode
                  ? const Color.fromRGBO(255, 255, 255, 0.7)
                  : Colors.black54,
              align: TextAlign.center,
              maxLines: null,
              overflow: TextOverflow.visible,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDarkMode) {
    return Align(
      alignment: Alignment.centerRight,
      child: AppText(
        title,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: isDarkMode
            ? const Color.fromRGBO(255, 255, 255, 0.9)
            : Colors.black87,
      ),
    );
  }

  Widget _buildFeaturesHorizontalList(bool isDarkMode, Size size) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: AboutScreenConstants.features.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final feature = AboutScreenConstants.features[index];
          return Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: isDarkMode
                ? const Color.fromRGBO(255, 255, 255, 0.07)
                : Colors.white,
            child: Container(
              width: size.width * 0.38,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    feature.icon,
                    size: 32,
                    color: isDarkMode ? Colors.tealAccent : Colors.teal,
                  ),
                  const SizedBox(height: 10),
                  AppText(
                    feature.title,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode
                        ? const Color.fromRGBO(255, 255, 255, 0.9)
                        : Colors.black87,
                    align: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDeveloperCardModern(
      BuildContext context, DeveloperInfo developer, bool isDarkMode) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => DeveloperDialog(
            developerInfo: developer,
            isDarkMode: isDarkMode,
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: isDarkMode
            ? const Color.fromRGBO(255, 255, 255, 0.07)
            : Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: isDarkMode
                    ? Colors.tealAccent.withOpacity(0.2)
                    : Colors.teal.withOpacity(0.2),
                child: Icon(Icons.person,
                    size: 32,
                    color: isDarkMode ? Colors.tealAccent : Colors.teal),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      developer.name,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode
                          ? const Color.fromRGBO(255, 255, 255, 0.9)
                          : Colors.black87,
                    ),
                    const SizedBox(height: 4),
                    AppText(
                      developer.role,
                      fontSize: 14,
                      color: isDarkMode
                          ? const Color.fromRGBO(255, 255, 255, 0.7)
                          : Colors.black54,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: developer.socialLinks.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: InkWell(
                            onTap: () => _launchURL(Uri.parse(entry.value)),
                            child: Icon(
                              _getSocialIcon(entry.key),
                              size: 22,
                              color:
                                  isDarkMode ? Colors.tealAccent : Colors.teal,
                            ),
                          ),
                        );
                      }).toList(),
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

  Widget _buildActionButtonsRow(BuildContext context, bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: AboutScreenConstants.actionButtons.map((button) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                backgroundColor: isDarkMode
                    ? Colors.tealAccent.withOpacity(0.15)
                    : Colors.teal.withOpacity(0.15),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () => _handleActionButtonTap(context, button),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    button.icon,
                    color: isDarkMode ? Colors.tealAccent : Colors.teal,
                    size: 24,
                  ),
                  const SizedBox(height: 6),
                  AppText(
                    button.title,
                    fontSize: 13,
                    color: isDarkMode
                        ? const Color.fromRGBO(255, 255, 255, 0.9)
                        : Colors.black87,
                    align: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
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
        // TODO: Add your iOS app ID here
        final uri = Uri.parse(
          Platform.isAndroid
              ? 'market://details?id=$appId'
              : 'https://apps.apple.com/app/idYOUR_IOS_APP_ID',
        );
        _launchURL(uri);
        break;
      case ActionButtonType.share:
        final packageInfo = await PackageInfo.fromPlatform();
        final appId = packageInfo.packageName;
        // TODO: Add your iOS app ID here
        final storeUrl = Platform.isAndroid
            ? 'https://play.google.com/store/apps/details?id=$appId'
            : 'https://apps.apple.com/app/id/YOUR_IOS_APP_ID';
        Share.share(''''
تطبيق صراط هو تطبيق إسلامي شامل يحتوي على العديد من المميزات مثل:

• مواقيت الصلاة
• اتجاه القبلة
• الأذكار الصباحية والمسائية
• الأربعين النووية
• السبحة الإلكترونية
• القرآن الكريم مع التفسير
• القراء المشهورين
• الراديو الإسلامي
• فيديوهات القرآن الكريم
• التقويم الهجري
• حاسبة الزكاة
• الهدف اليومي
• التنبيهات والإشعارات
• الوضع الليلي
• دعم اللغة العربية

تحميل التطبيق من هنا:
https://play.google.com/store/apps/details?id=com.serat.app.serat''');
        break;
      case ActionButtonType.feedback:
        final String email = 'arabianatech@gmail.com';
        final String subject = 'ملاحظات حول تطبيق صراط';
        final String body = 'هذه ملاحظاتي:\n';
        final Uri emailUri = Uri(
          scheme: 'mailto',
          path: email,
          query:
              'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
        );
        _launchURL(emailUri);
        break;
    }
  }

  IconData _getSocialIcon(String social) {
    switch (social) {
      case 'GitHub':
        return Icons.code;
      case 'LinkedIn':
        return Icons.work;
      case 'Facebook':
        return Icons.facebook;
      default:
        return Icons.link;
    }
  }
}
