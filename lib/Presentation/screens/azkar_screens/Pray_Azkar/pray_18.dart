import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class Pray18 extends StatelessWidget {
  const Pray18({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'كيف كان النبي يُسبح'),
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'كيف كان النبي يُسبح',
          azkarList: ['يَعْقِدُ التَّسْبِيحَ'],
          maxValues: [1],
        ),
      ),
    );
  }
}
