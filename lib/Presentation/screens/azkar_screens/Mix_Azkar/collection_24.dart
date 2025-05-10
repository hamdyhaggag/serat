import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class Mix24 extends StatelessWidget {
  const Mix24({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'دعاء من أصيب بمصيبة',
          azkarList: [
            'إنا لله وإنا إليه راجعون اللهم أجرني في مصيبتي واخلف لي خيرا منها',
          ],
          maxValues: [1],
        ),
      ),
    );
  }
}
