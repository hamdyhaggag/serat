import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class Roqia5 extends StatelessWidget {
  const Roqia5({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'الصلاة من أسباب العلاج',
          azkarList: [
            '{وَاسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ وَإِنَّهَا لَكَبِيرَةٌ إِلَّا عَلَى الْخَاشِعِينَ } [البقرة: 45].{يَاأَيُّهَا الَّذِينَ آمَنُوا اسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ إِنَّ اللَّهَ مَعَ الصَّابِرِينَ} [البقرة: 153]',
            'عن جُنْدَب الْقَسْرِيّ يَقُولُ : قَالَ رَسُولُ اللَّهِ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ : " مَنْ صَلَّى صَلَاةَ الصُّبْحِ فَهُوَ فِي ذِمَّةِ اللَّهِ ، فَلَا يَطْلُبَنَّكُمُ اللَّهُ مِنْ ذِمَّتِهِ بِشَيْءٍ ، فَإِنَّهُ مَنْ يَطْلُبْهُ مِنْ ذِمَّتِهِ بِشَيْءٍ يُدْرِكْهُ ، ثُمَّ يَكُبَّهُ عَلَى وَجْهِهِ فِي نَارِ جَهَنَّمَ "',
          ],
          maxValues: [1],
        ),
      ),
    );
  }
}
