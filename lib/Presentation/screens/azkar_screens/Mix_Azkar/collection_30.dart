import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class Mix30 extends StatelessWidget {
  const Mix30({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'دعـاء سجود التلاوة',
          azkarList: [
            'سجد وجهي للذي خلقه ،وشق سمعه وبصره بحوله وقوته ( فتبارك الله احسن الخالقين )',
          ],
          maxValues: [1],
        ),
      ),
    );
  }
}
