import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class Pray12 extends StatelessWidget {
  const Pray12({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'الصلاة على النبي بعد التشهد',
          azkarList: [
            'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَأَزْوَاجِهِ وَذُرِّيَّتِهِ ، كَمَا صَلَّيْتَ عَلَى آلِ إِبْرَاهِيمَ ، وَبَارِكْ عَلَى مُحَمَّدٍ وَأَزْوَاجِهِ وَذُرِّيَّتِهِ ، كَمَا بَارَكْتَ عَلَى آلِ إِبْرَاهِيمَ ، إِنَّكَ حَمِيدٌ مَجِيدٌ',
          ],
          maxValues: [1],
        ),
      ),
    );
  }
}
