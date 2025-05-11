import 'package:flutter/material.dart';
import 'package:serat/imports.dart';
import 'ruku_rise1.dart';
import 'ruku_rise2.dart';

class RukuRiseScreen extends StatelessWidget {
  final String title;
  const RukuRiseScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'دعاء الرفع من الركوع'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 15),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RukuRise1()),
                );
              },
              child: const CustomFolderRow(
                title: 'سَمِعَ اللَّهُ لِمَنْ حَمِدَهُ',
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RukuRise2()),
                );
              },
              child: const CustomFolderRow(title: 'رَبَّنَا وَلَكَ الْحَمْدُ'),
            ),
          ],
        ),
      ),
    );
  }
}
