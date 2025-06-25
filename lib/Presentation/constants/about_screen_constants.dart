import 'package:flutter/material.dart';
import 'package:serat/Presentation/models/feature_item.dart';
import 'package:serat/Presentation/models/developer_info.dart';

class AboutScreenConstants {
  static const String appName = 'تطبيق صراط';
  static const String appVersion = 'الإصدار 1.0.0';
  static const String mainFeaturesTitle = 'المميزات الرئيسية';
  static const String rateAppText = 'تقييم التطبيق';
  static const String shareAppText = 'مشاركة التطبيق';
  static const String developerText = 'تطوير التطبيق';
  static const String closeText = 'إغلاق';

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
      icon: Icons.book,
    ),
    FeatureItem(
      title: 'الأحاديث النبوية',
      description: 'كتب الأحاديث النبوية الشريفة',
      icon: Icons.menu_book_rounded,
    ),
  ];

  static const DeveloperInfo developerInfo = DeveloperInfo(
    name: 'حمدي حجاج',
    role: 'مطور تطبيقات Flutter',
    socialLinks: {
      'GitHub': 'https://github.com/serat',
      'LinkedIn': 'https://linkedin.com/in/serat',
      'Facebook': 'https://facebook.com/serat',
    },
  );

  static const String shareMessage = '''
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
https://play.google.com/store/apps/details?id=com.serat.app.serat''';
}
