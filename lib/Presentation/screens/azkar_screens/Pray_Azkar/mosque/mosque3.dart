import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class Mosque3 extends StatelessWidget {
  const Mosque3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'دعاء الخروج من المسجد'),
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'دعاء الخروج من المسجد',
          azkarList: [
            'صَلَّى عَلَى مُحَمَّدٍ وَسَلَّمَ ، وَقَالَ : " رَبِّ اغْفِرْ لِي ذُنُوبِي ، وَافْتَحْ لِي أَبْوَابَ فَضْلِكَ "',
            'فَلْيُسَلِّمْ عَلَى النَّبِيِّ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ ، وَلْيَقُلِ : اللَّهُمَّ اعْصِمْنِي مِنَ الشَّيْطَانِ الرَّجِيمِ',
          ],
          maxValues: [1, 1],
        ),
      ),
    );
  }
} 