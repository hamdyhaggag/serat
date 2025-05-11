import 'package:flutter/material.dart';
import 'package:serat/imports.dart';
import 'package:serat/features/azkar/presentation/screens/pray_azkar_screen.dart';
import 'Wodoo/wodoo.dart';
import 'azan/azan.dart';
import 'mosque/mosque.dart';
import 'ruku_rise/ruku_rise.dart';
import 'after_salam/after_salam.dart';

class PrayAzkar extends StatelessWidget {
  final String title;
  const PrayAzkar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'أذكار الصلاة'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 15),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AzanScreen(title: 'الأذان'),
                  ),
                );
              },
              child: const CustomFolderRow(title: 'الأذان'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Wodoo(title: 'الوضوء'),
                  ),
                );
              },
              child: const CustomFolderRow(title: 'الوضوء'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MosqueScreen(title: 'المسجد'),
                  ),
                );
              },
              child: const CustomFolderRow(title: 'المسجد'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            const PrayAzkarScreen(category: 'prayer_start'),
                  ),
                );
              },
              child: const CustomFolderRow(title: 'دعاء استفتاح الصلاة'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => const PrayAzkarScreen(
                          category: 'night_prayer_start',
                        ),
                  ),
                );
              },
              child: const CustomFolderRow(
                title: 'دعاء استفتاح الصلاة إذا قام من الليل',
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => const PrayAzkarScreen(
                          category: 'whispering_prayer',
                        ),
                  ),
                );
              },
              child: const CustomFolderRow(
                title: 'دعاء الوسوسة في الصلاة و القراءة',
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => const PrayAzkarScreen(category: 'ruku'),
                  ),
                );
              },
              child: const CustomFolderRow(title: 'دعاء الركوع'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            const RukuRiseScreen(title: 'دعاء الرفع من الركوع'),
                  ),
                );
              },
              child: const CustomFolderRow(title: 'دعاء الرفع من الركوع'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => const PrayAzkarScreen(category: 'sujood'),
                  ),
                );
              },
              child: const CustomFolderRow(title: 'دعاء السجود'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            const PrayAzkarScreen(category: 'between_sujood'),
                  ),
                );
              },
              child: const CustomFolderRow(title: 'دعاء الجلسة بين السجدتين'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            const PrayAzkarScreen(category: 'tashahhud'),
                  ),
                );
              },
              child: const CustomFolderRow(title: 'التشهد'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => const PrayAzkarScreen(
                          category: 'prayer_on_prophet',
                        ),
                  ),
                );
              },
              child: const CustomFolderRow(
                title: 'الصلاة على النبي بعد التشهد',
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            const PrayAzkarScreen(category: 'final_tashahhud'),
                  ),
                );
              },
              child: const CustomFolderRow(
                title: 'الدعاء بعد التشهد الأخير قبل السلام',
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            const AfterSalamScreen(title: 'الأذكار بعد السلام'),
                  ),
                );
              },
              child: const CustomFolderRow(title: 'الأذكار بعد السلام'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            const PrayAzkarScreen(category: 'istikhara'),
                  ),
                );
              },
              child: const CustomFolderRow(title: 'دعاء صلاة الاستخارة'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => const PrayAzkarScreen(category: 'qunoot'),
                  ),
                );
              },
              child: const CustomFolderRow(title: 'دعاء قنوت الوتر'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            const PrayAzkarScreen(category: 'after_witr'),
                  ),
                );
              },
              child: const CustomFolderRow(title: 'الذكر عقب السلام من الوتر'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            const PrayAzkarScreen(category: 'prophet_tasbeeh'),
                  ),
                );
              },
              child: const CustomFolderRow(title: 'كيف كان النبي يُسَّبح'),
            ),
          ],
        ),
      ),
    );
  }
}
