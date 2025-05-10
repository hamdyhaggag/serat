import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class Mix21 extends StatelessWidget {
  const Mix21({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'الدعاء عند إفطار الصائم'),
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'الدعاء عند إفطار الصائم',
          azkarList: ['ذهب الظمـأ ، وأبتلت العروق ، وثبت الأجر إن شاء الله'],
          maxValues: [1],
        ),
      ),
    );
  }
}
