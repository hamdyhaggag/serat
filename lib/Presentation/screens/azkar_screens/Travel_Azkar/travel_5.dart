import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class Travel5 extends StatelessWidget {
  const Travel5({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'الدعاء إذا عثر المركوب',
          azkarList: ['بسم الله'],
          maxValues: [1],
        ),
      ),
    );
  }
}
