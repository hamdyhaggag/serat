import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class Mix15 extends StatelessWidget {
  const Mix15({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'دعاء من رأى مبتلى',
          azkarList: [
            'الحمد لله الذي عافاني مما ابتلا به وفضلني على كثير ممن خلق تفضيلا',
          ],
          maxValues: [1],
        ),
      ),
    );
  }
}
