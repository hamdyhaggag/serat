import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class Sleep4 extends StatelessWidget {
  const Sleep4({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'من رأى الرؤيا أو الحلم',
          azkarList: [
            'فَلْيَنْفُثْ عَنْ يَسَارِهِ ثَلَاثًا ، وَلْيَتَعَوَّذْ بِاللَّهِ مِنْ شَرِّهَا (الحلم الذي رآه ثلاثًا) ، وَلْيَتَحَوَّلْ عَنْ جَنْبِهِ الَّذِي كَانَ عَلَيْهِ ، وَلَا يُخْبِرْ بِهَا أَحَدًا',
            'فَلْيَقُمْ فَلْيُصَلِّ ، وَلَا يُحَدِّثْ بِهَا (الحلم الذي رآها ) النَّاسَ',
            'فَلْيَحْمَدِ اللَّهَ عَلَيْهَا ، وَلْيُحَدِّثْ بِهَا \nفَلْيَسْتَعِذْ مِنْ شَرِّهَا ، وَلَا يَذْكُرْهَا لِأَحَدٍ',
            'فَلَا يُحَدِّثْ بِهِ إِلَّا مَنْ يُحِبُّ \nفَلْيَتَعَوَّذْ بِاللَّهِ مِنْ شَرِّهَا وَمِنْ شَرِّ الشَّيْطَانِ ، وَلْيَتْفِلْ ثَلَاثًا ، وَلَا يُحَدِّثْ بِهَا أَحَدًا',
          ],
          maxValues: [3],
        ),
      ),
    );
  }
}
