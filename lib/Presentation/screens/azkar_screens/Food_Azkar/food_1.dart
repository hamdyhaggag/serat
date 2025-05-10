import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class Food1 extends StatelessWidget {
  const Food1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'قبل الطعام',
          azkarList: [
            'بِسْمِ اللَّهِ ، فَإِنْ نَسِيَ فِي أَوَّلِهِ ، فَلْيَقُلْ بِسْمِ اللَّهِ فِي أَوَّلِهِ وَآخِرِهِ',
            'اللَّهُمَّ بَارِكْ لَنَا فِيهِ وَأَطْعِمْنَا خَيْرًا مِنْهُ ، وَإِذَا سُقِيَ لَبَنًا فَلْيَقُلِ : اللَّهُمَّ بَارِكْ لَنَا فِيهِ وَزِدْنَا مِنْهُ',
          ],
          maxValues: [1],
        ),
      ),
    );
  }
}
