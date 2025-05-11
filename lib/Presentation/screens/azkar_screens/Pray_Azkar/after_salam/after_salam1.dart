import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class AfterSalam1 extends StatelessWidget {
  const AfterSalam1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'أَسْتَغْفِرُ اللَّهَ'),
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'أَسْتَغْفِرُ اللَّهَ',
          azkarList: [
            'أَسْتَغْفِرُ اللَّهَ أَسْتَغْفِرُ اللَّهَ أَسْتَغْفِرُ اللَّهَ اللَّهُمَّ أَنْتَ السَّلاَمُ وَمِنْكَ السَّلاَمُ تَبَارَكْتَ يَا ذَا الْجَلاَلِ وَالإِكْرَامِ',
          ],
          maxValues: [1],
        ),
      ),
    );
  }
}
