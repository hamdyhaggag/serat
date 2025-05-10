import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class Mix13 extends StatelessWidget {
  const Mix13({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'ما يقال في المجلس',
          azkarList: ['رب اغفر لي وتب عليّ إنك أنت التواب الغفور'],
          maxValues: [1],
        ),
      ),
    );
  }
}
