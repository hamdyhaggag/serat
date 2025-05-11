import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class RukuRise2 extends StatelessWidget {
  const RukuRise2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'رَبَّنَا وَلَكَ الْحَمْدُ'),
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'رَبَّنَا وَلَكَ الْحَمْدُ',
          azkarList: ['رَبَّنَا وَلَكَ الْحَمْدُ'],
          maxValues: [1],
        ),
      ),
    );
  }
}
