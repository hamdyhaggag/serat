import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class Sleep3 extends StatelessWidget {
  const Sleep3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'دعاء الفزع في النوم',
          azkarList: [
            'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّةِ مِنْ غَضَبِهِ وَعِقَابِهِ وَشَرِّ عِبَادِهِ وَمِنْ هَمَزَاتِ الشَّيَاطِينِ وَأَنْ يَحْضُرُونِ',
          ],
          maxValues: [1],
        ),
      ),
    );
  }
}
