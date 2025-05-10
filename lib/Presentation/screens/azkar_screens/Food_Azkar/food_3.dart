import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class Food3 extends StatelessWidget {
  const Food3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'دعاء الضيف لصاحب الطعام',
          azkarList: [
            'اللَّهُمَّ بَارِكْ لَهُمْ فِي مَا رَزَقْتَهُمْ ، وَاغْفِرْ لَهُمْ ، وَارْحَمْهُمْ',
          ],
          maxValues: [1],
        ),
      ),
    );
  }
}
