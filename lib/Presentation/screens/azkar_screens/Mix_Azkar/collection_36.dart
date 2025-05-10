import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class Mix36 extends StatelessWidget {
  const Mix36({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'إذا أحسست بوجع في جسدك',
          azkarList: [
            'ضع يدك على الذي تألَّم من جسدك وقل: بسم الله ،ثلاثاً ،وقل سبع مرات: أعوذُ بالله وقُدْرَتِهِ من شَرِّ مَا أَجِدُ واُحَاذِرُ',
          ],
          maxValues: [1],
        ),
      ),
    );
  }
}
