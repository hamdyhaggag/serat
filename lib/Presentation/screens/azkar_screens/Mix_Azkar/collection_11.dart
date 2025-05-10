import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class Mix11 extends StatelessWidget {
  const Mix11({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'دعاء من استصعب عليه أمر',
          azkarList: [
            'اللهم لاسهل إلا ماجعلته سهلا وأنت تجعل الحزن إذا شئت سهلا',
          ],
          maxValues: [1],
        ),
      ),
    );
  }
}
