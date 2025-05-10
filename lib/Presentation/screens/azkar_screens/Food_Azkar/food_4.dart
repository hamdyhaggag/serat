import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class Food4 extends StatelessWidget {
  const Food4({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'الدعاء لمن سقاه',
          azkarList: [
            'اللَّهُمَّ أَطْعِمْ مَنْ أَطْعَمَنِي ، وَأَسْقِ مَنْ أَسْقَانِي',
          ],
          maxValues: [1],
        ),
      ),
    );
  }
}
