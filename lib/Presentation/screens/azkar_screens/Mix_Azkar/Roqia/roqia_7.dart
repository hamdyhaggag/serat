import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class Roqia7 extends StatelessWidget {
  const Roqia7({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'الحجامة من أسباب العلاج',
          azkarList: [
            'عَنْ أَنَسٍ رَضِيَ اللَّهُ عَنْهُ ، أَنَّهُ سُئِلَ عَنْ أَجْرِ الْحَجَّامِ ، فَقَالَ : احْتَجَمَ رَسُولُ اللَّهِ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ ، حَجَمَهُ أَبُو طَيْبَةَ ، وَأَعْطَاهُ صَاعَيْنِ مِنْ طَعَامٍ ، وَكَلَّمَ مَوَالِيَهُ فَخَفَّفُوا عَنْهُ ، وَقَالَ : " إِنَّ أَمْثَلَ مَا تَدَاوَيْتُمْ بِهِ الْحِجَامَةُ وَالْقُسْطُ الْبَحْرِيُّ " . وَقَالَ : " لَا تُعَذِّبُوا صِبْيَانَكُمْ بِالْغَمْزِ مِنَ الْعُذْرَةِ ، وَعَلَيْكُمْ بِالْقُسْطِ " .',
          ],
          maxValues: [1],
        ),
      ),
    );
  }
}
