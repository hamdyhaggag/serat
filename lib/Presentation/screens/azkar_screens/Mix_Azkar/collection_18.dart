import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class Mix18 extends StatelessWidget {
  const Mix18({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'دعاء المتزوج لنفسه'),
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'دعاء المتزوج لنفسه',
          azkarList: [
            'اللهم إني أسألك خيرها وخير ماجبلتها عليه وأعوذ بك من شرها وشر ماجبلتها عليه ، وإذا اشترى بعيراً فليأخذ بذروة سنامه وليقل مثل ذلك',
          ],
          maxValues: [1],
        ),
      ),
    );
  }
}
