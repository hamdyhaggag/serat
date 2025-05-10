import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class Travel4 extends StatelessWidget {
  const Travel4({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'الركوب',
          azkarList: [
            'بِسْمِ اللَّهِ',
            'الْحَمْدُ لِلَّهِ',
            'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ وَإِنَّا إِلَى رَبِّنَا لَمُنقَلِبُونَ',
            'الحمدلله',
            'الله اكبر',
            'سُبْحَانَكَ إِنِّي ظَلَمْتُ نَفْسِي ، فَاغْفِرْ لِي ، فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ . ثُمَّ ضَحِكَ',
          ],
          maxValues: [1, 1, 1, 3, 3, 1],
        ),
      ),
    );
  }
}
