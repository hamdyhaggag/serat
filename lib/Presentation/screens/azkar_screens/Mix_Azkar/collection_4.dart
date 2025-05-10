import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class Mix4 extends StatelessWidget {
  const Mix4({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'دعاء الهم والحزن',
          azkarList: [
            'اللهم إني عبدك ابن عبدك ابن أمتك ناصيتي بيدك ماض في حكمك ، عدل في قضاؤك أسألك بكل اسم هو لك سميت به نفسك أو أنزلته في كتابك ، أو علمته أحداً من خلقك أو استأثرت به في علم الغيب عندك أن تجعل القرآن ربيع قلبي ، ونور صدري وجلاء حزني وذهاب همي. \n اللهم إني أعوذ بك من الهم والحزن والعجز والكسل والبخل والجبن ، وضلع الدين وغلبة الرجال',
          ],
          maxValues: [1],
        ),
      ),
    );
  }
}
