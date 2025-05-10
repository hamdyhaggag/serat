import 'package:flutter/material.dart';
import 'package:serat/Presentation/Widgets/Azkar/azkar_model_view.dart';
import 'package:serat/imports.dart';

class Sleep2 extends StatelessWidget {
  const Sleep2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'الدعاء إذا تقلب ليلاً',
          azkarList: [
            'لَا إِلَهَ إِلَّا اللَّهُ الْوَاحِدُ الْقَهَّارُ ، رَبُّ السَّمَوَاتِ وَالْأَرْضِ وَمَا بَيْنَهُمَا الْعَزِيزُ الْغَفَّارُ',
            'مَا مِنْ مُسْلِمٍ يَبِيتُ عَلَى ذِكْرٍ طَاهِرًا فَيَتَعَارُّ مِنَ اللَّيْلِ ، فَيَسْأَلُ اللَّهَ خَيْرًا مِنَ الدُّنْيَا وَالْآخِرَةِ إِلَّا أَعْطَاهُ إِيَّاهُ',
            'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ ، الْحَمْدُ لِلَّهِ ، وَسُبْحَانَ اللَّهِ ، وَلَا إِلَهَ إِلَّا اللَّهُ ، وَاللَّهُ أَكْبَرُ ، وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ ، ثُمَّ قَالَ : اللَّهُمَّ اغْفِرْ لِي أَوْ دَعَا اسْتُجِيبَ لَهُ',
          ],
          maxValues: [1],
        ),
      ),
    );
  }
}
