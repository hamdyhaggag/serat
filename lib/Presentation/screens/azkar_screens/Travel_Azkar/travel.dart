import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class TravelAzkar extends StatelessWidget {
  final String title;
  const TravelAzkar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'أذكار السفر'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 15),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Travel1()),
                );
              },
              child: const CustomFolderRow(title: 'دعاء المسافر للمقيم'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Travel2()),
                );
              },
              child: const CustomFolderRow(title: 'دعاء المقيم للمسافر'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Travel3()),
                );
              },
              child: const CustomFolderRow(title: 'السفر'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Travel4()),
                );
              },
              child: const CustomFolderRow(title: 'الركوب'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Travel5()),
                );
              },
              child: const CustomFolderRow(title: ' الدعاء إذا عثر المركوب'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Travel6()),
                );
              },
              child: const CustomFolderRow(
                title: 'التكبير و التسبيح في سير السفر',
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Travel7()),
                );
              },
              child: const CustomFolderRow(title: 'نزول المنزل'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Travel8()),
                );
              },
              child: const CustomFolderRow(title: 'دعاء المسافر إذا أصبح'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Travel9()),
                );
              },
              child: const CustomFolderRow(title: 'دخول البلدة'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Travel10()),
                );
              },
              child: const CustomFolderRow(title: 'ذكر الرجوع من السفر '),
            ),
          ],
        ),
      ),
    );
  }
}
