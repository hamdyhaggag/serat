import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class Travel1 extends StatelessWidget {
  const Travel1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'دعاء المسافر للمقيم',
          azkarList: [
            'اسْتَوْدَعْتُكَ اللَّهَ الَّذِي لَا يُضِيعُ وَدَائِعَهُ',
          ],
          maxValues: [1],
        ),
      ),
    );
  }
}
