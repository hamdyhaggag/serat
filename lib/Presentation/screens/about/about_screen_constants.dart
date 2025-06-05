import 'package:flutter/material.dart';
import 'package:serat/Presentation/screens/about/models/feature_item.dart';
import 'package:serat/Presentation/screens/about/models/developer_info.dart';

enum ActionButtonType {
  rate,
  share,
  feedback,
}

class ActionButton {
  final String title;
  final IconData icon;
  final ActionButtonType type;

  const ActionButton({
    required this.title,
    required this.icon,
    required this.type,
  });
}

class AboutScreenConstants {
  static const String appName = 'سراط';
  static const String appVersion = 'الإصدار 1.0.0';
  static const String appDescription =
      'تطبيق سراط هو تطبيق إسلامي شامل يوفر مجموعة من الخدمات والموارد الإسلامية للمستخدمين.';

  static const List<FeatureItem> features = [
    FeatureItem(
      title: 'القرآن الكريم',
      description: 'استماع وتلاوة القرآن الكريم مع خيارات متعددة للقراء',
      icon: Icons.menu_book,
    ),
    FeatureItem(
      title: 'الأذكار',
      description: 'أذكار الصباح والمساء وأذكار متنوعة',
      icon: Icons.favorite,
    ),
    FeatureItem(
      title: 'التقويم الهجري',
      description: 'عرض التقويم الهجري مع المناسبات الإسلامية',
      icon: Icons.calendar_today,
    ),
    FeatureItem(
      title: 'القبلة',
      description: 'تحديد اتجاه القبلة بدقة',
      icon: Icons.explore,
    ),
    FeatureItem(
      title: 'أسماء الله الحسنى',
      description: 'معرفة أسماء الله الحسنى وشرحها وفضلها',
      icon: Icons.auto_awesome,
    ),
    FeatureItem(
      title: 'التاريخ الإسلامي',
      description: 'أحداث ومواقف مهمة من التاريخ الإسلامي',
      icon: Icons.history,
    ),
  ];

  static const List<DeveloperInfo> developers = [
    DeveloperInfo(
      name: 'أحمد محمد',
      role: 'مطور رئيسي',
      socialLinks: {
        'GitHub': 'https://github.com/ahmed',
        'LinkedIn': 'https://linkedin.com/in/ahmed',
      },
    ),
    DeveloperInfo(
      name: 'محمد علي',
      role: 'مصمم واجهات المستخدم',
      socialLinks: {
        'GitHub': 'https://github.com/mohammed',
        'LinkedIn': 'https://linkedin.com/in/mohammed',
      },
    ),
  ];

  static const List<ActionButton> actionButtons = [
    ActionButton(
      title: 'تقييم التطبيق',
      icon: Icons.star,
      type: ActionButtonType.rate,
    ),
    ActionButton(
      title: 'مشاركة التطبيق',
      icon: Icons.share,
      type: ActionButtonType.share,
    ),
    ActionButton(
      title: 'إرسال ملاحظات',
      icon: Icons.feedback,
      type: ActionButtonType.feedback,
    ),
  ];
}
