import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class Pray7 extends StatelessWidget {
  const Pray7({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'دعاء الركوع',
          azkarList: [
            'سُبْحَانَ رَبِّيَ الْعَظِيمِ',
            'سُبْحَانَكَ اللَّهُمَّ رَبَّنَا وَبِحَمْدِكَ ، اللَّهُمَّ اغْفِرْ لِي',
            'سُبُّوحٌ قُدُّوسٌ ، رَبُّ الْمَلَائِكَةِ وَالرُّوحِ',
            'اللَّهُمَّ لَكَ رَكَعْتُ ، وَبِكَ آمَنْتُ ، وَلَكَ أَسْلَمْتُ ، خَشَعَ لَكَ سَمْعِي وَبَصَرِي وَمُخِّي وَعَظْمِي وَعَصَبِي وَمَا اسْتَقَلَّتْ بِهِ قَدَمِي ، لِلَّهِ رَبِّ الْعَالَمِينَ',
            'سُبْحَانَ ذِي الْجَبَرُوتِ وَالْمَلَكُوتِ وَالْكِبْرِيَاءِ وَالْعَظَمَةِ',
          ],
          maxValues: [3],
        ),
      ),
    );
  }
}
