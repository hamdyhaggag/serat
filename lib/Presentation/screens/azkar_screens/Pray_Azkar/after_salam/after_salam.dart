import 'package:flutter/material.dart';
import 'package:serat/imports.dart';
import 'after_salam1.dart';

class AfterSalamScreen extends StatelessWidget {
  final String title;
  const AfterSalamScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'الأذكار بعد السلام'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 15),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AfterSalam1()),
                );
              },
              child: const CustomFolderRow(title: 'أَسْتَغْفِرُ اللَّهَ'),
            ),
          ],
        ),
      ),
    );
  }
}
