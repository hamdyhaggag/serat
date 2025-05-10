import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class Travel8 extends StatelessWidget {
  const Travel8({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'دعاء المسافر إذا أصبح',
          azkarList: [
            'سَمِعَ سَامِعٌ بِحَمْدِ اللَّهِ وَنِعْمَتِهِ وَحُسْنِ بَلَائِهِ عَلَيْنَا ، رَبَّنَا صَاحِبْنَا فَأَفْضِلْ عَلَيْنَا ، عَائِذٌ بِاللَّهِ مِنَ النَّارِ يَرْفَعُ بِهِ صَوْتَهُ',
          ],
          maxValues: [3],
        ),
      ),
    );
  }
}
