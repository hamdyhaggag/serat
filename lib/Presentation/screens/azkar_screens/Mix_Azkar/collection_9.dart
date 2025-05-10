import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class Mix9 extends StatelessWidget {
  const Mix9({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'دعاء نزول المطر'),
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'دعاء نزول المطر',
          azkarList: ['اللهم صيبا نافعا'],
          maxValues: [1],
        ),
      ),
    );
  }
}
