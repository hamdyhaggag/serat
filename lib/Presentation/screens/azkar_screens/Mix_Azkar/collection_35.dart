import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class Mix35 extends StatelessWidget {
  const Mix35({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'سيد الاستغفار',
          azkarList: [
            'اللهم أنت ربي لا إله إلا أنت ، خلقتني و أنا عبدك وأنا على عهدك و وعدك ما استطعت أعوذ بك من شر ما صنعت ، أبوء لك بنعمتك علىّ و أبوء بذنبي ، فاغفر لي فإنه لا يغفر الذنوب إلا أنت',
          ],
          maxValues: [1],
        ),
      ),
    );
  }
}
