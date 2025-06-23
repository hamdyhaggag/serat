// Professional and well-documented constants for the About screen.
import 'package:flutter/material.dart';
import 'package:serat/Presentation/screens/about/models/feature_item.dart';
import 'package:serat/Presentation/screens/about/models/developer_info.dart';

/// Enum representing the types of action buttons available on the About screen.
enum ActionButtonType {
  rate,
  share,
  feedback,
}

/// Model for an action button displayed on the About screen.
class ActionButton {
  /// The display title of the button.
  final String title;

  /// The icon to show for the button.
  final IconData icon;

  /// The type of action this button performs.
  final ActionButtonType type;

  const ActionButton({
    required this.title,
    required this.icon,
    required this.type,
  });
}

abstract class AboutScreenConstants {
  /// The app's display name.
  static const String appName = 'صراط';

  /// The app's version string.
  static const String appVersion = 'الإصدار 1.0.0';

  /// A brief description of the app.
  static const String appDescription =
      'تطبيق صراط هو تطبيق إسلامي شامل يوفر مجموعة من الخدمات والموارد الإسلامية للمستخدمين.';

  /// List of main features presented in the app.
  static const List<FeatureItem> features = [
    FeatureItem(
      title: 'مواقيت الصلاة',
      description: 'تحديد مواقيت الصلاة بدقة حسب موقعك',
      icon: Icons.access_time,
    ),
    FeatureItem(
      title: 'اتجاه القبلة',
      description: 'تحديد اتجاه القبلة باستخدام البوصلة',
      icon: Icons.explore,
    ),
    FeatureItem(
      title: 'القرآن الكريم',
      description: 'القرآن الكريم مع التفسير والقراء',
      icon: Icons.menu_book,
    ),
    FeatureItem(
      title: 'بطاقات القرآن',
      description: 'تصفح القرآن الكريم بطريقة سهلة',
      icon: Icons.book,
    ),
    FeatureItem(
      title: 'القراء',
      description: 'استماع للقراء المشهورين',
      icon: Icons.record_voice_over,
    ),
    FeatureItem(
      title: 'الراديو الإسلامي',
      description: 'استماع للراديو الإسلامي المباشر',
      icon: Icons.radio,
    ),
    FeatureItem(
      title: 'روائع القصص',
      description: 'قصص إسلامية هادفة',
      icon: Icons.auto_stories,
    ),
    FeatureItem(
      title: 'حاسبة الزكاة',
      description: 'حساب الزكاة بسهولة',
      icon: Icons.calculate,
    ),
    FeatureItem(
      title: 'الأذكار',
      description: 'أذكار الصباح والمساء مع التنبيهات',
      icon: Icons.favorite,
    ),
    FeatureItem(
      title: 'كتب الأحاديث',
      description: 'كتب الأحاديث النبوية الشريفة',
      icon: Icons.menu_book_rounded,
    ),
    FeatureItem(
      title: 'اختبار إسلامي',
      description: 'اختبر معلوماتك الدينية',
      icon: Icons.quiz,
    ),
    FeatureItem(
      title: 'التاريخ الإسلامي',
      description: 'أحداث ومواقف مهمة من التاريخ الإسلامي',
      icon: Icons.history,
    ),
    FeatureItem(
      title: 'الهدف اليومي',
      description: 'تتبع إنجازاتك اليومية',
      icon: Icons.flag,
    ),
    FeatureItem(
      title: 'الإشعارات',
      description: 'تنبيهات ومتابعة مستمرة',
      icon: Icons.notifications_active,
    ),
    FeatureItem(
      title: 'الوضع الليلي',
      description: 'دعم الوضع الليلي لراحة العين',
      icon: Icons.nightlight_round,
    ),
    FeatureItem(
      title: 'دعم اللغة العربية',
      description: 'تجربة استخدام كاملة باللغة العربية',
      icon: Icons.language,
    ),
  ];

  /// List of developers who contributed to the app.
  static const List<DeveloperInfo> developers = [
    DeveloperInfo(
      name: 'حمدي حجاج',
      role: 'مطور التطبيق',
      socialLinks: {
        'GitHub': 'https://github.com/hamdyhaggag',
        'LinkedIn': 'https://linkedin.com/in/hamdyhaggag74',
      },
    ),
  ];

  /// List of action buttons available on the About screen.
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
