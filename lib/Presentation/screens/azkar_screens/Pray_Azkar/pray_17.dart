import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class Pray17 extends StatelessWidget {
  const Pray17({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'الذكر عقب السلام من الوتر',
          azkarList: [
            'سُبْحَانَ الْمَلِكِ الْقُدُّوسِ " . ثَلَاثًا ، وَيَرْفَعُ صَوْتَهُ بِالثَّالِثَةِ',
          ],
          maxValues: [3],
        ),
      ),
    );
  }
}
