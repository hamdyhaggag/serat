import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class Travel10 extends StatelessWidget {
  const Travel10({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'ذكر الرجوع من السفر',
          azkarList: [
            'يُكَبِّرُ عَلَى كُلِّ شَرَفٍ مِنَ الْأَرْضِ ثَلَاثَ تَكْبِيرَاتٍ الله أكبر الله أكبر الله أكبر',
          ],
          maxValues: [3],
        ),
      ),
    );
  }
}
