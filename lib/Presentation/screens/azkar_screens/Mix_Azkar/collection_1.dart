import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class Mix1 extends StatelessWidget {
  const Mix1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'دعاء لبس الثوب',
          azkarList: [
            'الحمدُ للهِ الّذي كَساني هذا (الثّوب) وَرَزَقَنيه مِنْ غَـيـْرِ حَولٍ مِنّي وَلا قـوّة',
          ],
          maxValues: [1],
        ),
      ),
    );
  }
}
