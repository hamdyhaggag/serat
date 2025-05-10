import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class Wodoo2 extends StatelessWidget {
  const Wodoo2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'الذكر بعد الفراغ من الوضوء',
          azkarList: [
            'أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ وَأَنَّ مُحَمَّدًا عَبْدُ اللَّهِ وَرَسُولُهُ',
            'سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ ، أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا أَنْتَ ، أَسْتَغْفِرُكَ وَأَتُوبُ إِلَيْكَ',
          ],
          maxValues: [1],
        ),
      ),
    );
  }
}
