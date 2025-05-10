import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class Pray8 extends StatelessWidget {
  const Pray8({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'دعاء الرفع من الركوع',
          azkarList: [
            'سَمِعَ اللَّهُ لِمَنْ حَمِدَهُ',
            'رَبَّنَا وَلَكَ الْحَمْدُ حَمْدًا كَثِيرًا طَيِّبًا مُبَارَكًا فِيهِ',
            'رَبَّنَا لَكَ الْحَمْدُ مِلْءَ السَّمَوَاتِ وَالْأَرْضِ وَمِلْءَ مَا شِئْتَ مِنْ شَيْءٍ بَعْدُ ، أَهْلَ الثَّنَاءِ وَالْمَجْدِ . أَحَقُّ مَا قَالَ الْعَبْدُ - وَكُلُّنَا لَكَ عَبْدٌ - اللَّهُمَّ لَا مَانِعَ لِمَا أَعْطَيْتَ ، وَلَا مُعْطِيَ لِمَا مَنَعْتَ ، وَلَا يَنْفَعُ ذَا الْجَدِّ مِنْكَ الْجَدُّ',
          ],
          maxValues: [1],
        ),
      ),
    );
  }
}
