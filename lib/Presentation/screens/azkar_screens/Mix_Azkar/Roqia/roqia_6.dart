import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class Roqia6 extends StatelessWidget {
  const Roqia6({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'الدعاء في ثلث الليل الأخير',
          azkarList: [
            'عَنْ أَبِي هُرَيْرَةَ رَضِيَ اللَّهُ عَنْهُ ، أَنَّ رَسُولَ اللَّهِ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ قَالَ : " يَنْزِلُ رَبُّنَا تَبَارَكَ وَتَعَالَى كُلَّ لَيْلَةٍ إِلَى السَّمَاءِ الدُّنْيَا ، حِينَ يَبْقَى ثُلُثُ اللَّيْلِ الْآخِرُ ، يَقُولُ : مَنْ يَدْعُونِي فَأَسْتَجِيبَ لَهُ ؟ مَنْ يَسْأَلُنِي فَأُعْطِيَهُ ؟ مَنْ يَسْتَغْفِرُنِي فَأَغْفِرَ لَهُ ؟ " .',
          ],
          maxValues: [1],
        ),
      ),
    );
  }
}
