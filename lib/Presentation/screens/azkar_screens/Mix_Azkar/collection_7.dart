import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class Mix7 extends StatelessWidget {
  const Mix7({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'دعاء الرعد'),
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'دعاء الرعد',
          azkarList: ['سبحان الله الذي يسبح الرعد بحمده والملائكة من خيفته'],
          maxValues: [1],
        ),
      ),
    );
  }
}
