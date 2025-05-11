import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class RukuRise1 extends StatelessWidget {
  const RukuRise1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'سَمِعَ اللَّهُ لِمَنْ حَمِدَهُ'),
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'سَمِعَ اللَّهُ لِمَنْ حَمِدَهُ',
          azkarList: [
            'سَمِعَ اللَّهُ لِمَنْ حَمِدَهُ',
          ],
          maxValues: [1],
        ),
      ),
    );
  }
} 