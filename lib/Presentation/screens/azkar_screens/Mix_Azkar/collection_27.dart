import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class Mix27 extends StatelessWidget {
  const Mix27({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'ما يعوذ به الأولاد',
          azkarList: [
            'أعيذكما بكلمات الله التامة من كل شيطان وهامة ، ومن كل عين لامة',
          ],
          maxValues: [1],
        ),
      ),
    );
  }
}
