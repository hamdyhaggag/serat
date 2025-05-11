import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class Azan1 extends StatelessWidget {
  const Azan1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'رد المؤذن'),
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'رد المؤذن',
          azkarList: [
            'يردد بعد المؤذن : اللَّهُ أَكْبَرُ اللَّهُ أَكْبَرُ اللَّهُ أَكْبَرُ اللَّهُ أَكْبَرُ ، أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ ، أَشْهَدُ أَنَّ مُحَمَّدًا رَسُولُ اللَّهِ أَشْهَدُ أَنَّ مُحَمَّدًا رَسُولُ اللَّهِ ، حَيَّ عَلَى الصَّلَاةِ لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ ، حَيَّ عَلَى الْفَلَاحِ لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ ، اللَّهُ أَكْبَرُ اللَّهُ أَكْبَرُ ، لَا إِلَهَ إِلَّا اللَّهُ',
          ],
          maxValues: [1],
        ),
      ),
    );
  }
}
