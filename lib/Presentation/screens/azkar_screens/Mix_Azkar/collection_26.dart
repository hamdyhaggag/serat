import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class Mix26 extends StatelessWidget {
  const Mix26({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'المريض الذي يئس من حياته',
          azkarList: ['اللهم اغفر لي وارحمني والحقني بالرفيق الأعلى'],
          maxValues: [1],
        ),
      ),
    );
  }
}
