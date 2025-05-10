import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class Pray6 extends StatelessWidget {
  const Pray6({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'دعاء الوسوسة في الصلاة',
          azkarList: ['أعوذ بالله من الشيطان الرجيم واتفل على يسارك'],
          maxValues: [3],
        ),
      ),
    );
  }
}
