import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class Pray10 extends StatelessWidget {
  const Pray10({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'دعاء الجلسة بين السجدتين',
          azkarList: [
            'رَبِّ اغْفِرْ لِي، رَبِّ اغْفِرْ لِي',
            'رَبِّ اغْفِرْ لِي ، وَارْحَمْنِي ، وَاجْبُرْنِي ، وَارْفَعْنِي ، وَعَافِنِي ، وَارْزُقْنِي ، وَاهْدِنِي',
          ],
          maxValues: [1],
        ),
      ),
    );
  }
}
