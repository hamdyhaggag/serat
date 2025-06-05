import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:serat/Presentation/screens/about/models/developer_info.dart';
import 'package:serat/imports.dart';

class DeveloperDialog extends StatelessWidget {
  final DeveloperInfo developerInfo;
  final bool isDarkMode;

  const DeveloperDialog({
    Key? key,
    required this.developerInfo,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
              developerInfo.name,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDarkMode
                  ? const Color.fromRGBO(255, 255, 255, 0.9)
                  : const Color.fromRGBO(0, 0, 0, 0.9),
            ),
            const SizedBox(height: 8),
            AppText(
              developerInfo.role,
              fontSize: 16,
              color: isDarkMode
                  ? const Color.fromRGBO(255, 255, 255, 0.7)
                  : const Color.fromRGBO(0, 0, 0, 0.7),
            ),
            const SizedBox(height: 20),
            ...developerInfo.socialLinks.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildContactButton(
                  entry.key,
                  _getIconForSocial(entry.key),
                  entry.value,
                ),
              ),
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
    );
  }

  Widget _buildContactButton(String title, IconData icon, String url) {
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

  IconData _getIconForSocial(String social) {
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
