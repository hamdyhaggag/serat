import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class Food5 extends StatelessWidget {
  const Food5({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'الدعاء إذا أفطر عند أهل بيت',
          azkarList: [
            'أَفْطَرَ عِنْدَكُمُ الصَّائِمُونَ ، وَأَكَلَ طَعَامَكُمُ الْأَبْرَارُ ، وَصَلَّتْ عَلَيْكُمُ الْمَلَائِكَةُ',
          ],
          maxValues: [1],
        ),
      ),
    );
  }
}
