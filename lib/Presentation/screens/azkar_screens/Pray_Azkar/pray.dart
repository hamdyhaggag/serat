import 'package:flutter/material.dart';
import 'package:serat/Presentation/screens/azkar_screens/Pray_Azkar/pray_3.dart';
import 'package:serat/imports.dart';

import 'Wodoo/wodoo.dart';
import 'azan/azan.dart';
import 'pray_10.dart';
import 'pray_11.dart';
import 'pray_12.dart';
import 'pray_13.dart';
import 'pray_14.dart';
import 'pray_15.dart';
import 'pray_16.dart';
import 'pray_17.dart';
import 'pray_18.dart';
import 'pray_4.dart';
import 'pray_5.dart';
import 'pray_6.dart';
import 'pray_7.dart';
import 'pray_8.dart';
import 'pray_9.dart';

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
                    builder: (context) => const Azan(title: 'الأذان'),
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
                  MaterialPageRoute(builder: (context) => const Pray3()),
                );
              },
              child: const CustomFolderRow(title: 'المسجد'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Pray4()),
                );
              },
              child: const CustomFolderRow(title: 'دعاء استفتاح الصلاة'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Pray5()),
                );
              },
              child: const CustomFolderRow(
                title: ' دعاء استفتاح الصلاة إذا قام من الليل',
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Pray6()),
                );
              },
              child: const CustomFolderRow(
                title: ' دعاء الوسوسة في الصلاة و القراءة',
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Pray7()),
                );
              },
              child: const CustomFolderRow(title: ' دعاء الركوع'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Pray8()),
                );
              },
              child: const CustomFolderRow(title: ' دعاء الرفع من الركوع'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Pray9()),
                );
              },
              child: const CustomFolderRow(title: 'دعاء السجود'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Pray10()),
                );
              },
              child: const CustomFolderRow(title: ' دعاء الجلسة بين السجدتين'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Pray11()),
                );
              },
              child: const CustomFolderRow(title: ' التشهد'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Pray12()),
                );
              },
              child: const CustomFolderRow(
                title: ' الصلاة على النبي بعد التشهد',
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Pray13()),
                );
              },
              child: const CustomFolderRow(
                title: ' الدعاء بعد التشهد الأخير قبل السلام',
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Pray14()),
                );
              },
              child: const CustomFolderRow(title: ' الأذكار بعد السلام '),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Pray15()),
                );
              },
              child: const CustomFolderRow(title: ' دعاء صلاة الاستخارة'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Pray16()),
                );
              },
              child: const CustomFolderRow(title: ' دعاء قنوت الوتر'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Pray17()),
                );
              },
              child: const CustomFolderRow(title: ' الذكر عقب السلام من الوتر'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Pray18()),
                );
              },
              child: const CustomFolderRow(title: ' كيف كان النبي  يُسَّبح'),
            ),
          ],
        ),
      ),
    );
  }
}
