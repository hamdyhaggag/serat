import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class Mix3 extends StatelessWidget {
  const Mix3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'دعاء الكرب',
          azkarList: [
            'لا إله إلا الله العظيم الحليم، لا إله إلا الله رب العرش العظيم، لا إله إلا الله رب السماوات، ورب الأرض ورب العرش الكريم',
          ],
          maxValues: [1],
        ),
      ),
    );
  }
}
