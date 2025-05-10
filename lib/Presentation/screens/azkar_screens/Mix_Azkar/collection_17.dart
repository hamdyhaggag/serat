import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class Mix17 extends StatelessWidget {
  const Mix17({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'الدعاء للمتزوج',
          azkarList: ['بارك الله لك ، وبارك عليك ، وجمع بينكما في خير'],
          maxValues: [1],
        ),
      ),
    );
  }
}
