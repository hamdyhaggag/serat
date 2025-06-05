import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:serat/Presentation/Config/constants/colors.dart';
import 'package:serat/Presentation/Widgets/Shared/custom_app_bar.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xff1F1F1F) : Colors.white,
      appBar: const CustomAppBar(title: 'سياسة الخصوصية'),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: SingleChildScrollView(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              '''نهتم بخصوصيتك و سرية معلوماتك الشخصية ، فيما يلي نظرة عامة على كيفية جمع واستخدام المعلومات في تطبيقنا:

1. البيانات التي نجمعها:
• مواقيت الصلاة واتجاه القبلة: 
  - نجمع مواقيت الصلاة ومعلومات اتجاه القبلة لتوفير خدمات دقيقة
  - هذه المعلومات تُخزَّن محليًا على جهازك ولا تُشارك مع جهات أخرى
  - يتم تحديث البيانات تلقائياً عند تغيير موقعك

• البيانات المحلية:
  - إعدادات التطبيق وتفضيلات المستخدم
  - الإشارات المرجعية والملاحظات
  - جميع هذه البيانات تُخزَّن محلياً على جهازك

2. مدة الاحتفاظ بالبيانات:
• البيانات المحلية: تُحتفظ بها طالما التطبيق مثبت على جهازك
• يمكنك حذف جميع البيانات المحلية من خلال:
  - إزالة التطبيق
  - استخدام خيار "مسح البيانات" في إعدادات التطبيق

3. حقوق المستخدم:
• يمكنك في أي وقت:
  - الوصول إلى بياناتك المخزنة محلياً
  - حذف بياناتك من خلال إزالة التطبيق
  - تعطيل جمع بيانات الموقع من إعدادات الجهاز

4. التحليلات والإحصائيات:
• نجمع بيانات مجمعة ومجهولة المصدر حول استخدام التطبيق
• هذه البيانات تستخدم لتحسين أداء التطبيق وتجربة المستخدم
• لا تتضمن معلومات شخصية أو قابلة للتحديد
• يمكنك تعطيل جمع البيانات التحليلية من إعدادات التطبيق

5. الأمان:
• نستخدم تقنيات تشفير لحماية البيانات المحلية
• لا نقوم بجمع أو تخزين بيانات الدفع
• جميع الاتصالات الشبكية تستخدم بروتوكول HTTPS

6. التحديثات:
• قد نقوم بتحديث سياسة الخصوصية من وقت لآخر
• سيتم إخطارك بأي تغييرات جوهرية
• استمرار استخدام التطبيق يعني الموافقة على التحديثات

7. التواصل:
• إذا كان لديك أي أسئلة حول سياسة الخصوصية، يمكنك التواصل معنا عبر:
  - البريد الإلكتروني: arabianatech@gmail.com
  - صفحة التطبيق على متجر Google Play''',
              style: TextStyle(
                color: isDarkMode ? Colors.white : AppColors.primaryColor,
                fontSize: 20.0,
                fontFamily: 'DIN',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
