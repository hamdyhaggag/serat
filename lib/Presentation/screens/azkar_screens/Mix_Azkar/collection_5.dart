import 'package:flutter/material.dart';
import 'package:serat/imports.dart'; // Ensure this import includes AzkarCubit and AzkarModelView

class Mix5 extends StatelessWidget {
  const Mix5({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'دعاء قضاء الدين',
          azkarList: ['اللهم اكفنى بحلالك عن حرامك وأغننى بفضلك عمن سواك'],
          maxValues: [1],
        ),
      ),
    );
  }
}
