import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class Mix2 extends StatelessWidget {
  const Mix2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'دعاء لبس الثوب الجديد',
          azkarList: [
            'اللهم لك الحمد أنت كسوتنيه، أسألك من خيره',
          ],
          maxValues: [1],
        ),
      ),
    );
  }
}
