import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class Mix19 extends StatelessWidget {
  const Mix19({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'الدعاء قبل الجماع'),
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'الدعاء قبل الجماع',
          azkarList: ['بسم الله ـ اللهم جنبنا الشيطان، وجنب الشيطان مارزقتنا'],
          maxValues: [1],
        ),
      ),
    );
  }
}
