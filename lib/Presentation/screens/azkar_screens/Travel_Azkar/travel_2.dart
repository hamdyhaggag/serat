import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class Travel2 extends StatelessWidget {
  const Travel2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'دعاء المقيم للمسافر',
          azkarList: [
            'أَسْتَوْدِعُ اللَّهَ دِينَكَ وَأَمَانَتَكَ وَخَوَاتِيمَ عَمَلِكَ',
            'زَوَّدَكَ اللَّهُ التَّقْوَى ، وَغَفَرَ ذَنْبَكَ ، وَيَسَّرَ لَكَ الْخَيْرَ حَيْثُمَا كُنْتَ',
          ],
          maxValues: [1],
        ),
      ),
    );
  }
}
