import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:serat/Presentation/Config/constants/colors.dart';
import 'package:serat/Presentation/Widgets/Shared/custom_app_bar.dart';

class TermsOfService extends StatelessWidget {
  const TermsOfService({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xff1F1F1F) : Colors.white,
      appBar: const CustomAppBar(title: 'شروط الخدمة'),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: SingleChildScrollView(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              '''شروط استخدام تطبيق صراط

1. قبول الشروط:
• باستخدامك تطبيق صراط، فإنك توافق على الالتزام بهذه الشروط
• إذا كنت لا توافق على هذه الشروط، يرجى عدم استخدام التطبيق
• نحتفظ بالحق في تعديل هذه الشروط في أي وقت

2. استخدام التطبيق:
• يجب استخدام التطبيق وفقاً للقوانين المعمول بها
• يجب استخدام التطبيق للأغراض الدينية والروحية فقط
• يحظر استخدام التطبيق لأي غرض غير قانوني أو ضار

3. المحتوى:
• جميع المحتوى الديني (القرآن، الأحاديث، الأذكار) يتم تقديمه كما هو
• نحن لا نتحمل المسؤولية عن أي تفسيرات خاطئة للمحتوى
• يجب مراجعة أي معلومات دينية مع مصادر موثوقة

4. المسؤولية:
• نحن لا نتحمل المسؤولية عن أي أضرار مباشرة أو غير مباشرة
• نحن لا نضمن دقة مواقيت الصلاة أو اتجاه القبلة بنسبة 100%
• يجب التحقق من المعلومات المهمة من مصادر موثوقة

5. الملكية الفكرية:
• جميع حقوق الملكية الفكرية للتطبيق محفوظة
• يحظر نسخ أو توزيع أو تعديل أي جزء من التطبيق
• يمكن استخدام المحتوى الديني للأغراض الشخصية فقط

6. التحديثات:
• قد نقوم بتحديث التطبيق من وقت لآخر
• قد تتطلب التحديثات تغييرات في هذه الشروط
• سيتم إخطارك بأي تغييرات جوهرية

7. إنهاء الخدمة:
• نحتفظ بالحق في إنهاء أو تعليق الخدمة في أي وقت
• يمكنك إيقاف استخدام التطبيق في أي وقت
• ستظل بعض الشروط سارية حتى بعد إنهاء الخدمة

8. التواصل:
• إذا كان لديك أي أسئلة حول شروط الخدمة، يمكنك التواصل معنا عبر:
  - البريد الإلكتروني: arabianatech@gmail.com
  - صفحة التطبيق على متجر Google Play

تاريخ آخر تحديث: ${DateTime.now().year}/${DateTime.now().month}/${DateTime.now().day}''',
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
