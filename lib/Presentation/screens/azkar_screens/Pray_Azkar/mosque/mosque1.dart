import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class Mosque1 extends StatelessWidget {
  const Mosque1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'دعاء دخول المسجد'),
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'دعاء دخول المسجد',
          azkarList: [
            'أَعُوذُ بِاللَّهِ الْعَظِيمِ وَبِوَجْهِهِ الْكَرِيمِ وَسُلْطَانِهِ الْقَدِيمِ مِنَ الشَّيْطَانِ الرَّجِيمِ',
            'صَلَّى عَلَى مُحَمَّدٍ وَسَلَّمَ ، وَقَالَ : " رَبِّ اغْفِرْ لِي ذُنُوبِي ، وَافْتَحْ لِي أَبْوَابَ رَحْمَتِكَ "',
            'فَلْيُسَلِّمْ عَلَى النَّبِيِّ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ ، وَلْيَقُلِ : اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ',
          ],
          maxValues: [1, 1, 1],
        ),
      ),
    );
  }
}
