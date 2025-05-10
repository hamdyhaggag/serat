import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class Travel6 extends StatelessWidget {
  const Travel6({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'التكبير و التسبيح في سير السفر',
          azkarList: [
            'يُكَبِّرُ عَلَى كُلِّ شَرَفٍ مِنَ الْأَرْضِ ثَلَاثَ تَكْبِيرَاتٍ الله أكبر الله أكبر الله أكبر',
            'كُنَّا إِذَا صَعِدْنَا كَبَّرْنَا الله أكبر ، وَإِذَا نَزَلْنَا سَبَّحْنَا سبحان الله',
          ],
          maxValues: [3, 1],
        ),
      ),
    );
  }
}
