import 'package:flutter/material.dart';
import 'package:serat/Presentation/screens/about/models/feature_item.dart';
import 'package:serat/Presentation/screens/about/models/developer_info.dart';
import 'package:serat/Presentation/screens/about/widgets/feature_item_widget.dart';
import 'package:serat/Presentation/screens/about/widgets/action_button_widget.dart';
import 'package:serat/Presentation/screens/about/widgets/developer_dialog.dart';
import 'package:serat/Presentation/screens/about/about_screen_constants.dart';
import 'package:serat/imports.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const AppText(
          'عن التطبيق',
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppInfo(isDarkMode),
              const SizedBox(height: 30),
              _buildFeaturesList(isDarkMode),
              const SizedBox(height: 30),
              _buildDevelopersSection(context, isDarkMode),
              const SizedBox(height: 30),
              _buildActionButtons(context, isDarkMode),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppInfo(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDarkMode
                ? const Color.fromRGBO(255, 255, 255, 0.05)
                : const Color.fromRGBO(0, 0, 0, 0.02),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? const Color.fromRGBO(255, 255, 255, 0.1)
                      : const Color.fromRGBO(0, 0, 0, 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.info_outline,
                  size: 40,
                  color: isDarkMode
                      ? const Color.fromRGBO(255, 255, 255, 0.9)
                      : const Color.fromRGBO(0, 0, 0, 0.9),
                ),
              ),
              const SizedBox(height: 20),
              AppText(
                AboutScreenConstants.appName,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDarkMode
                    ? const Color.fromRGBO(255, 255, 255, 0.9)
                    : const Color.fromRGBO(0, 0, 0, 0.9),
              ),
              const SizedBox(height: 8),
              AppText(
                AboutScreenConstants.appVersion,
                fontSize: 16,
                color: isDarkMode
                    ? const Color.fromRGBO(255, 255, 255, 0.7)
                    : const Color.fromRGBO(0, 0, 0, 0.7),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        AppText(
          AboutScreenConstants.appDescription,
          fontSize: 16,
          color: isDarkMode
              ? const Color.fromRGBO(255, 255, 255, 0.7)
              : const Color.fromRGBO(0, 0, 0, 0.7),
        ),
      ],
    );
  }

  Widget _buildFeaturesList(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'المميزات',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: isDarkMode
              ? const Color.fromRGBO(255, 255, 255, 0.9)
              : const Color.fromRGBO(0, 0, 0, 0.9),
        ),
        const SizedBox(height: 15),
        ...AboutScreenConstants.features.map(
          (feature) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: FeatureItemWidget(
              feature: feature,
              isDarkMode: isDarkMode,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDevelopersSection(BuildContext context, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'المطورون',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: isDarkMode
              ? const Color.fromRGBO(255, 255, 255, 0.9)
              : const Color.fromRGBO(0, 0, 0, 0.9),
        ),
        const SizedBox(height: 15),
        ...AboutScreenConstants.developers.map(
          (developer) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildDeveloperCard(context, developer, isDarkMode),
          ),
        ),
      ],
    );
  }

  Widget _buildDeveloperCard(
    BuildContext context,
    DeveloperInfo developer,
    bool isDarkMode,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showDeveloperDialog(context, developer, isDarkMode),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(15),
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
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? const Color.fromRGBO(255, 255, 255, 0.1)
                      : const Color.fromRGBO(0, 0, 0, 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  size: 24,
                  color: isDarkMode
                      ? const Color.fromRGBO(255, 255, 255, 0.9)
                      : const Color.fromRGBO(0, 0, 0, 0.9),
                ),
              ),
              const SizedBox(width: 15),
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
                          : const Color.fromRGBO(0, 0, 0, 0.9),
                    ),
                    const SizedBox(height: 4),
                    AppText(
                      developer.role,
                      fontSize: 14,
                      color: isDarkMode
                          ? const Color.fromRGBO(255, 255, 255, 0.7)
                          : const Color.fromRGBO(0, 0, 0, 0.7),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
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

  Widget _buildActionButtons(BuildContext context, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'روابط سريعة',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: isDarkMode
              ? const Color.fromRGBO(255, 255, 255, 0.9)
              : const Color.fromRGBO(0, 0, 0, 0.9),
        ),
        const SizedBox(height: 15),
        ...AboutScreenConstants.actionButtons.map(
          (button) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ActionButtonWidget(
              title: button.title,
              icon: button.icon,
              onTap: () => _handleActionButtonTap(context, button),
              isDarkMode: isDarkMode,
            ),
          ),
        ),
      ],
    );
  }

  void _showDeveloperDialog(
    BuildContext context,
    DeveloperInfo developer,
    bool isDarkMode,
  ) {
    showDialog(
      context: context,
      builder: (context) => DeveloperDialog(
        developerInfo: developer,
        isDarkMode: isDarkMode,
      ),
    );
  }

  void _handleActionButtonTap(BuildContext context, ActionButton button) {
    switch (button.type) {
      case ActionButtonType.rate:
        // TODO: Implement rate functionality
        break;
      case ActionButtonType.share:
        // TODO: Implement share functionality
        break;
      case ActionButtonType.feedback:
        // TODO: Implement feedback functionality
        break;
    }
  }
}
