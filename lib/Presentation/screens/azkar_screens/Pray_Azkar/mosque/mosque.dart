import 'package:flutter/material.dart';
import 'package:serat/imports.dart';
import 'mosque1.dart';
import 'mosque2.dart';
import 'mosque3.dart';

class MosqueScreen extends StatelessWidget {
  final String title;
  const MosqueScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'المسجد'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 15),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Mosque1()),
                );
              },
              child: const CustomFolderRow(title: 'دعاء دخول المسجد'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Mosque2()),
                );
              },
              child: const CustomFolderRow(title: 'دعاء الخروج الي الصلاه'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Mosque3()),
                );
              },
              child: const CustomFolderRow(title: 'دعاء الخروج من المسجد'),
            ),
          ],
        ),
      ),
    );
  }
} 