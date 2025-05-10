import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class Mix32 extends StatelessWidget {
  const Mix32({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'دعاء دخول السوق',
          azkarList: [
            'لا إله إلا الله وحده لا شريك له، له الملك وله الحمد يحيي ويميت وهو حي لا يموت بيده الخير وهو على كل شيء قدير (كتب الله له ألف ألف حسنة ومحا عنه ألف ألف سيئة ورفع له ألف الف درجة وفي رواية: وبنى له بيتا في الجنة).\n بسم الله، اللهم إني أسألك خير هذه السوق، وخير ما فيها، وأعوذ بك من شرها وشر ما فيها، اللهم إني أعوذ بك أن أصيب بها يميناً فاجرةً، أو صفقة خاسرة',
          ],
          maxValues: [1],
        ),
      ),
    );
  }
}
