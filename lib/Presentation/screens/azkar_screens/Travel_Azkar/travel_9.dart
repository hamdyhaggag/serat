import 'package:flutter/material.dart';
import 'package:serat/Presentation/Widgets/Azkar/azkar_model_view.dart';
import 'package:serat/imports.dart';

class Travel9 extends StatelessWidget {
  const Travel9({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'دخول البلدة',
          azkarList: [
            'اللَّهُمَّ رَبَّ السَّمَوَاتِ السَّبْعِ وَمَا أَظْلَلْنَ ، وَرَبَّ الْأَرَضِينَ السَّبْعِ وَمَا أَقْلَلْنَ ، وَرَبَّ الشَّيَاطِينِ وَمَا أَضْلَلْنَ ، وَرَبَّ الرِّيَاحِ وَمَا ذَرَيْنَ ، فَإِنَّا نَسْأَلُكَ خَيْرَ هَذِهِ الْقَرْيَةِ وَخَيْرَ أَهْلِهَا ، وَنَعُوذُ بِكَ مِنْ شَرِّهَا وَشَرِّ أَهْلِهَا وَشَرِّ مَا فِيهَا',
          ],
          maxValues: [1],
        ),
      ),
    );
  }
}
