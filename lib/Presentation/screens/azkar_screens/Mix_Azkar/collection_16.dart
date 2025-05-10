import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class Mix16 extends StatelessWidget {
  const Mix16({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'دعـاء الغـضـب',
          azkarList: ['أعوذ بالله من الشيطان الرجيـم'],
          maxValues: [1],
        ),
      ),
    );
  }
}
