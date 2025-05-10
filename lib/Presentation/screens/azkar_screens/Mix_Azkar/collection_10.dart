import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class Mix10 extends StatelessWidget {
  const Mix10({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'دعاء ركوب الدابة',
          azkarList: [
            'بسم الله ، الحمد لله ، سبحان الذي سخر لنا هذا وماكنا له مقرنين وإنا إلى ربنا لمنقلبون، الحمد لله ، الحمد لله ، الحمد لله ، الله اكبر ، الله أكبر ، الله أكبر ، سبحانك اللهم إني ظلمت نفسي فاغفر لي ، فإنه لايغفر الذنوب إلا أنت',
          ],
          maxValues: [1],
        ),
      ),
    );
  }
}
