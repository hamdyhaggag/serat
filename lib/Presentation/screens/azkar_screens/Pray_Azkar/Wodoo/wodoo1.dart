import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class Wodoo1 extends StatelessWidget {
  const Wodoo1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'الذكر قبل الوضوء',
          azkarList: ['بسم الله'],
          maxValues: [1],
        ),
      ),
    );
  }
}
