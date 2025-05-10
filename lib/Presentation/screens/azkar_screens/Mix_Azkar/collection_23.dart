import 'package:flutter/material.dart';
import 'package:serat/imports.dart'; // Ensure correct imports

class Mix23 extends StatelessWidget {
  const Mix23({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'دعاء رؤية الهلال'),
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'دعاء رؤية الهلال',
          azkarList: [
            'الله أكبر ، اللهم أهله علينا بالأمن ، والإيمان والسلامة ، والإسلام ، والتوفيق لما تحب وترضى ربنا وربك الله',
          ],
          maxValues: [1],
        ),
      ),
    );
  }
}
