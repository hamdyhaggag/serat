import 'package:flutter/material.dart';
import 'package:serat/imports.dart'; // Ensure this import includes AzkarCubit and AzkarModelView

class Mix6 extends StatelessWidget {
  const Mix6({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'دعاء الريح'),
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'دعاء الريح',
          azkarList: [
            'اللهم إنى أسألك خيرها، وخير ما فيها، وخير ما أرسلت به، وأعوذ بك من شرها، وشر ما فيها وشر ما أرسلت به',
          ],
          maxValues: [1],
        ),
      ),
    );
  }
}
