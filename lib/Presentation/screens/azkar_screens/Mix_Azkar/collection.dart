import 'package:flutter/material.dart';
import 'package:serat/Presentation/Widgets/Shared/custom_app_bar.dart';
import 'package:serat/Presentation/Widgets/Shared/custom_folder_row.dart';
import 'collection_1.dart';
import 'collection_10.dart';
import 'collection_11.dart';
import 'collection_12.dart';
import 'collection_13.dart';
import 'collection_14..dart';
import 'collection_15.dart';
import 'collection_16.dart';
import 'collection_17.dart';
import 'collection_18.dart';
import 'collection_19.dart';
import 'collection_2.dart';
import 'collection_20.dart';
import 'collection_21.dart';
import 'collection_22.dart';
import 'collection_23.dart';
import 'collection_24.dart';
import 'collection_25.dart';
import 'collection_26.dart';
import 'collection_27.dart';
import 'collection_28.dart';
import 'collection_29.dart';
import 'collection_3.dart';
import 'collection_30.dart';
import 'collection_31.dart';
import 'collection_32.dart';
import 'collection_33.dart';
import 'collection_34.dart';
import 'collection_35.dart';
import 'collection_36.dart';
import 'collection_4.dart';
import 'collection_5.dart';
import 'collection_6.dart';
import 'collection_7.dart';
import 'collection_8.dart';
import 'collection_9.dart';

class CollectionAzkar extends StatelessWidget {
  final String title;
  const CollectionAzkar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'أذكار متفرقة'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 15),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Mix1()),
                );
              },
              child: const CustomFolderRow(title: 'دعاء لبس الثوب'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Mix2()),
                );
              },
              child: const CustomFolderRow(title: 'دعاء لبس الثوب الجديد'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Mix3()),
                );
              },
              child: const CustomFolderRow(title: 'دعاء الكرب'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Mix4()),
                );
              },
              child: const CustomFolderRow(title: 'دعاء الهم والحزن'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Mix5()),
                );
              },
              child: const CustomFolderRow(title: ' دعاء قضاء الدين'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Mix6()),
                );
              },
              child: const CustomFolderRow(title: ' دعاء الريح'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Mix7()),
                );
              },
              child: const CustomFolderRow(title: ' دعاء الرعـد'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Mix8()),
                );
              },
              child: const CustomFolderRow(title: ' دعاء زيارة القبور'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Mix9()),
                );
              },
              child: const CustomFolderRow(title: 'دعاء  نزول المطر'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Mix10()),
                );
              },
              child: const CustomFolderRow(
                title: ' دعاء ركوب الدابة أو ما يقوم مقامها',
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Mix11()),
                );
              },
              child: const CustomFolderRow(title: ' دعاء من استصعب عليه أمر'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Mix12()),
                );
              },
              child: const CustomFolderRow(title: ' دعـاء الخوف من الشــرك'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Mix13()),
                );
              },
              child: const CustomFolderRow(title: ' ما يقال في المجلس'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Mix14()),
                );
              },
              child: const CustomFolderRow(title: ' كفارة المجلس '),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Mix15()),
                );
              },
              child: const CustomFolderRow(title: ' دعاء من رأى مبتلى'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Mix16()),
                );
              },
              child: const CustomFolderRow(title: 'دعـاء الغـضـب'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Mix17()),
                );
              },
              child: const CustomFolderRow(title: ' الدعاء للمتزوج'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Mix18()),
                );
              },
              child: const CustomFolderRow(title: ' دعاء المتزوج لنفسه'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Mix19()),
                );
              },
              child: const CustomFolderRow(title: 'الدعاء قبل الجماع '),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Mix20()),
                );
              },
              child: const CustomFolderRow(title: 'دعاء العطاس '),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Mix21()),
                );
              },
              child: const CustomFolderRow(title: ' الدعاء عند افطار الصائم'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Mix22()),
                );
              },
              child: const CustomFolderRow(
                title: 'الدعاء إذا أفطر عند أهل بيت ',
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Mix23()),
                );
              },
              child: const CustomFolderRow(title: 'دعاء رؤية الهلال '),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Mix24()),
                );
              },
              child: const CustomFolderRow(title: ' دعاء من أصيب بمصيبة'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Mix25()),
                );
              },
              child: const CustomFolderRow(title: ' الدعاء للمريض في عيادته'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Mix26()),
                );
              },
              child: const CustomFolderRow(
                title: 'دعاء المريض الذي يئس من حياته ',
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Mix27()),
                );
              },
              child: const CustomFolderRow(title: ' ما يعوذ به الأولاد'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Mix28()),
                );
              },
              child: const CustomFolderRow(
                title: 'دعاء لقاء العدو وذي السلطان ',
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Mix29()),
                );
              },
              child: const CustomFolderRow(title: ' دعـاء صـلاة الاستخـارة'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Mix30()),
                );
              },
              child: const CustomFolderRow(title: ' دعـاء سجود التلاوة'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Mix31()),
                );
              },
              child: const CustomFolderRow(title: 'دعاء الاستفتاح '),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Mix32()),
                );
              },
              child: const CustomFolderRow(title: ' دعاء دخول السوق'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Mix33()),
                );
              },
              child: const CustomFolderRow(
                title: 'عند فعل الذنب أو ارتكاب المعصية',
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Mix34()),
                );
              },
              child: const CustomFolderRow(
                title: 'الدعاء عند سماع أصوات الحيوانات',
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Mix35()),
                );
              },
              child: const CustomFolderRow(title: 'سيد الاستغفار '),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Mix36()),
                );
              },
              child: const CustomFolderRow(
                title: 'الدعاء إذا أحسست بوجع في جسدك',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
