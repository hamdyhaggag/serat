import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class Mix12 extends StatelessWidget {
  const Mix12({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'دعاء الخوف من الشرك',
          azkarList: [
            'اللهم إني أعوذ بك أن أشرك بك وأنا أعلم ، وأستغفرك لما لا أعلم'
          ],
          maxValues: [1],
        ),
      ),
    );
  }
}
