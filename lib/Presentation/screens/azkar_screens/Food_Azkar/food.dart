import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

import 'food_1.dart';
import 'food_2.dart';
import 'food_3.dart';
import 'food_4.dart';
import 'food_5.dart';

class FoodAzkar extends StatelessWidget {
  final String title;
  const FoodAzkar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'أذكار الطعام'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 15),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Food1()),
                );
              },
              child: const CustomFolderRow(title: 'قبل الطعام'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Food2()),
                );
              },
              child: const CustomFolderRow(title: 'بعد الطعام'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Food3()),
                );
              },
              child: const CustomFolderRow(title: 'دعاء الضيف لصاحب الطعام'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Food4()),
                );
              },
              child: const CustomFolderRow(
                title: 'الدعاء لمن سقاه أو إذا أراد ذلك',
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Food5()),
                );
              },
              child: const CustomFolderRow(
                title: ' الدعاء إذا أفطر عند أهل بيت',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
