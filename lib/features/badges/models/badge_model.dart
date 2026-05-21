import 'package:flutter/material.dart';

enum BadgeCategory {
  family,
  quran,
  smile,
  knowledge,
  gentleness,
  goodDeed,
  honesty,
  gratitude,
  patience,
}

class BadgeModel {
  final String id;
  final String name;
  final String hadith;
  final String source;
  final int requiredCount;
  final BadgeCategory category;
  final IconData icon;
  final List<Color> gradientColors;
  final List<String> examples;
  int progressCount;
  bool isUnlocked;

  BadgeModel({
    required this.id,
    required this.name,
    required this.hadith,
    required this.source,
    required this.requiredCount,
    required this.category,
    required this.icon,
    required this.gradientColors,
    required this.examples,
    this.progressCount = 0,
    this.isUnlocked = false,
  });

  double get progressPercent =>
      (progressCount / requiredCount).clamp(0.0, 1.0);

  bool get isComplete => progressCount >= requiredCount;

  BadgeModel copyWith({
    int? progressCount,
    bool? isUnlocked,
  }) {
    return BadgeModel(
      id: id,
      name: name,
      hadith: hadith,
      source: source,
      requiredCount: requiredCount,
      category: category,
      icon: icon,
      gradientColors: gradientColors,
      examples: examples,
      progressCount: progressCount ?? this.progressCount,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'progressCount': progressCount,
        'isUnlocked': isUnlocked,
      };

  static List<BadgeModel> get allBadges => [
        BadgeModel(
          id: 'best_to_family',
          name: 'خيركم لأهله',
          hadith: 'خيركم خيركم لأهله، وأنا خيركم لأهلي.',
          source: 'الترمذي وابن ماجه — صحيح',
          requiredCount: 5,
          category: BadgeCategory.family,
          icon: Icons.favorite_rounded,
          gradientColors: [const Color(0xffE84393), const Color(0xffC62E7A)],
          examples: [
            'مساعدة الأم في تنظيف المنزل',
            'الجلوس مع الأب في المساء',
            'مساعدة الأخ الأصغر في المذاكرة',
            'إعداد وجبة للعائلة',
            'الاستماع لمشاكل الأهل',
          ],
        ),
        BadgeModel(
          id: 'quran_teacher',
          name: 'خيركم من تعلم القرآن وعلّمه',
          hadith: 'خيركم من تعلم القرآن وعلمه.',
          source: 'البخاري (5027)',
          requiredCount: 5,
          category: BadgeCategory.quran,
          icon: Icons.menu_book_rounded,
          gradientColors: [const Color(0xff1E6B4A), const Color(0xff137058)],
          examples: [
            'قراءة جزء من القرآن يومياً',
            'مشاركة تلاوة مع صديق',
            'تعليم طفل سورة قصيرة',
            'الاستماع لتلاوة مع شرح',
            'حفظ آية ومشاركتها مع الآخرين',
          ],
        ),
        BadgeModel(
          id: 'smile_charity',
          name: 'تبسّمك في وجه أخيك صدقة',
          hadith: 'تبسمك في وجه أخيك لك صدقة.',
          source: 'الترمذي (1956) — صحيح',
          requiredCount: 10,
          category: BadgeCategory.smile,
          icon: Icons.sentiment_satisfied_rounded,
          gradientColors: [const Color(0xffF5A623), const Color(0xffD4880A)],
          examples: [
            'الابتسام عند مقابلة شخص',
            'الابتسام عند الرد على الهاتف',
            'الابتسام عند التعامل مع البائع',
            'الابتسام عند مساعدة الآخرين',
            'الابتسام عند الاستيقاظ صباحاً',
          ],
        ),
        BadgeModel(
          id: 'seek_knowledge',
          name: 'من سلك طريقاً يلتمس فيه علماً',
          hadith:
              'من سلك طريقاً يلتمس فيه علماً سهّل الله له به طريقاً إلى الجنة.',
          source: 'مسلم (2699)',
          requiredCount: 3,
          category: BadgeCategory.knowledge,
          icon: Icons.school_rounded,
          gradientColors: [const Color(0xff4A90D9), const Color(0xff2C6FAB)],
          examples: [
            'قراءة حديث عن الصبر',
            'دراسة حديث عن الأمانة',
            'تعلم حديث عن الصدق',
            'مشاركة حديث مع الأصدقاء',
            'كتابة ملخص للحديث',
          ],
        ),
        BadgeModel(
          id: 'gentleness',
          name: 'يحب الرفق',
          hadith: 'إن الله رفيق يحب الرفق في الأمر كله.',
          source: 'البخاري (6927) ومسلم (2165)',
          requiredCount: 3,
          category: BadgeCategory.gentleness,
          icon: Icons.spa_rounded,
          gradientColors: [const Color(0xff9B59B6), const Color(0xff7D3C98)],
          examples: [
            'التحدث بهدوء مع من أخطأ',
            'مساعدة شخص بحب',
            'الاستماع للآخرين باهتمام',
            'التعامل بلطف مع الأطفال',
            'الرد على الإساءة بالحسنى',
          ],
        ),
        BadgeModel(
          id: 'guide_to_good',
          name: 'الدال على الخير كفاعله',
          hadith: 'الدال على الخير كفاعله.',
          source: 'مسلم (1893)',
          requiredCount: 5,
          category: BadgeCategory.goodDeed,
          icon: Icons.share_rounded,
          gradientColors: [const Color(0xff27AE60), const Color(0xff1E8449)],
          examples: [
            'مشاركة أذكار الصباح أو المساء',
            'التذكير بالبسملة والحمد عند الطعام',
            'تعليم دعاء النوم',
            'تعليم دعاء الخروج من المنزل',
            'مشاركة دعاء قبل النوم',
          ],
        ),
        BadgeModel(
          id: 'truthful_trustworthy',
          name: 'الصادق الأمين',
          hadith: 'عليكم بالصدق فإن الصدق يهدي إلى البر.',
          source: 'البخاري (6094) ومسلم (2607)',
          requiredCount: 3,
          category: BadgeCategory.honesty,
          icon: Icons.verified_rounded,
          gradientColors: [const Color(0xff2980B9), const Color(0xff1F618D)],
          examples: [
            'رد الأمانات لأصحابها',
            'الصدق في الحديث',
            'الاعتراف بالخطأ',
            'الوفاء بالوعد',
            'حفظ أسرار الآخرين',
          ],
        ),
        BadgeModel(
          id: 'gratitude',
          name: 'من لا يشكر الناس لا يشكر الله',
          hadith: 'من لا يشكر الناس لا يشكر الله.',
          source: 'أبو داود (4811) — صحيح',
          requiredCount: 3,
          category: BadgeCategory.gratitude,
          icon: Icons.volunteer_activism_rounded,
          gradientColors: [const Color(0xffE67E22), const Color(0xffCA6F1E)],
          examples: [
            'شكر الأم على وجبة الإفطار',
            'شكر المعلم على الشرح',
            'شكر السائق على المساعدة',
            'شكر البائع على المعاملة الطيبة',
            'شكر الصديق على الدعم',
          ],
        ),
        BadgeModel(
          id: 'no_anger',
          name: 'لا تغضب',
          hadith: 'لا تغضب.',
          source: 'البخاري (6116)',
          requiredCount: 3,
          category: BadgeCategory.patience,
          icon: Icons.self_improvement_rounded,
          gradientColors: [const Color(0xff16A085), const Color(0xff0E6655)],
          examples: [
            'العد إلى 10 عند الغضب',
            'الاستعاذة من الشيطان',
            'تغيير الوضعية عند الغضب',
            'الوضوء عند الغضب',
            'الصمت لحظة الغضب',
          ],
        ),
      ];
}
