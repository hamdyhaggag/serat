import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class Azan3 extends StatelessWidget {
  const Azan3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'الدعاء بين الأذان و الإقامة',
          azkarList: [
            'الدُّعَاءُ لَا يُرَدُّ بَيْنَ الْأَذَانِ وَالْإِقَامَةِ',
          ],
          maxValues: [1],
        ),
      ),
    );
  }
}
