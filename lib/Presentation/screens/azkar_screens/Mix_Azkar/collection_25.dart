import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class Mix25 extends StatelessWidget {
  const Mix25({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'الدعاء للمريض في عيادته',
          azkarList: [
            'لابأس طهور إن شاء الله مامن عبد مسلم يعود مريضاً لم يحضر أجله فيقول سبع مرات : أسأل الله العظيم رب العرش العظيم أن يشفيك إلا عوفي',
          ],
          maxValues: [1],
        ),
      ),
    );
  }
}
