import 'package:flutter/material.dart';
import 'morning_azkar_screen.dart';
import 'evening_azkar_screen.dart';
import 'sleep_azkar_screen.dart';

class AzkarScreen extends StatelessWidget {
  const AzkarScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الأذكار'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'أذكار الصباح'),
              Tab(text: 'أذكار المساء'),
              Tab(text: 'أذكار النوم'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            MorningAzkarScreen(),
            EveningAzkarScreen(),
            SleepAzkarScreen(),
          ],
        ),
      ),
    );
  }
}
