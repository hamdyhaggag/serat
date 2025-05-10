import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class Mix8 extends StatelessWidget {
  const Mix8({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'دعاء زيارة القبور'),
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'دعاء زيارة القبور',
          azkarList: [
            'السلام عليكم أهل الديار من المؤمنين والمسلمين، وإنا إن شاء الله بكم لاحقون ويرحم الله المستقدمين منا والمستأخرين، أسأل الله لنا ولكم العافية',
          ],
          maxValues: [1],
        ),
      ),
    );
  }
}
