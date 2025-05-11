import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class SleepAzkar extends StatelessWidget {
  final String title;
  const SleepAzkar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'أذكار النوم'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 15),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SleepAzkarScreen(),
                  ),
                );
              },
              child: const CustomFolderRow(title: 'أذكار النوم'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            const SleepAzkarScreen(category: 'night_turning'),
                  ),
                );
              },
              child: const CustomFolderRow(title: 'الدعاء إذا تقلب ليلاً'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => const SleepAzkarScreen(
                          category: 'nightmare_prayer',
                        ),
                  ),
                );
              },
              child: const CustomFolderRow(title: 'دعاء الفزع في النوم'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            const SleepAzkarScreen(category: 'dream_prayer'),
                  ),
                );
              },
              child: const CustomFolderRow(
                title: 'ما يفعل من رأى الرؤيا او الحلم',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
