# Serat - صراط

تطبيق إسلامي شامل يوفر مجموعة من المميزات للمستخدمين المسلمين.

## المميزات

- مواقيت الصلاة الدقيقة
- اتجاه القبلة
- القرآن الكريم مع التفسير
- الأذكار الصباحية والمسائية
- الأربعين النووية
- السبحة الإلكترونية
- القراء المشهورين
- الراديو الإسلامي
- فيديوهات القرآن الكريم
- التقويم الهجري
- حاسبة الزكاة
- الهدف اليومي
- التنبيهات والإشعارات
- الوضع الليلي
- دعم اللغة العربية

## متطلبات التطوير

- Flutter SDK >= 3.2.3
- Dart SDK >= 3.0.0
- Android Studio / VS Code
- Git

## إعداد المشروع

1. قم بنسخ المشروع:
```bash
git clone https://github.com/your-username/serat.git
cd serat
```

2. قم بتثبيت التبعيات:
```bash
flutter pub get
```

3. قم بإعداد مفتاح API لـ YouTube:
   - احصل على مفتاح API من [Google Cloud Console](https://console.cloud.google.com)
   - قم بتفعيل YouTube Data API v3
   - قم بإضافة المفتاح إلى متغيرات البيئة:
     ```bash
     # Linux/macOS
     export YOUTUBE_API_KEY=your_api_key_here
     
     # Windows (PowerShell)
     $env:YOUTUBE_API_KEY="your_api_key_here"
     ```

4. قم بتشغيل التطبيق:
```bash
flutter run
```

## الأمان والخصوصية

- يتم تخزين جميع البيانات محلياً على جهاز المستخدم
- لا يتم جمع أي بيانات شخصية
- يتم استخدام HTTPS لجميع الاتصالات الشبكية
- يمكن للمستخدمين حذف بياناتهم في أي وقت

## المساهمة

نرحب بمساهماتكم! يرجى اتباع الخطوات التالية:

1. قم بعمل Fork للمشروع
2. قم بإنشاء فرع جديد (`git checkout -b feature/amazing-feature`)
3. قم بعمل Commit للتغييرات (`git commit -m 'Add some amazing feature'`)
4. قم بعمل Push إلى الفرع (`git push origin feature/amazing-feature`)
5. قم بفتح Pull Request

## الترخيص

هذا المشروع مرخص تحت رخصة MIT - انظر ملف [LICENSE](LICENSE) للتفاصيل.

## التواصل

- البريد الإلكتروني: arabianatech@gmail.com
- صفحة التطبيق: [Google Play Store](https://play.google.com/store/apps/details?id=com.serat.app)
