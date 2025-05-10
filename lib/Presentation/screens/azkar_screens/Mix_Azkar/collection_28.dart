import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class Mix28 extends StatelessWidget {
  const Mix28({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'لقاء العدو وذي السلطان',
          azkarList: [
            'حسـبنا الله ونعـم الـوكـيل\nاللهم إنا نجعلك في نحورهم ونعوذ بك من شرورهم\nاللهم أنت عضدي ، وأنت نصيري ، بك أجول وبك أصول وبك أقاتل',
          ],
          maxValues: [1],
        ),
      ),
    );
  }
}
