import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class Mix33 extends StatelessWidget {
  const Mix33({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'فعل الذنب',
          azkarList: [
            'كما أخبرنا رسول الله صلى الله عليه وسلم ( ما من عبد يذنب ذنباً فيتوضأ فيحسن الطهور،ثم يقوم فيصلي ركعتين ، ثم يستغفر الله لذلك الذنب إلاَّ غُفر له )',
          ],
          maxValues: [1],
        ),
      ),
    );
  }
}
