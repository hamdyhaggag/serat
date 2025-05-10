import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class Mix22 extends StatelessWidget {
  const Mix22({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'الدعاء إذا أفطر عند أهل بيت'),
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: const AzkarModelView(
          title: 'الدعاء إذا أفطر عند أهل بيت',
          azkarList: [
            'أفطر عندكم الصائمون ، وأكل طعامكم الأبرار ، وصلت عليكم الملائكة',
          ],
          maxValues: [1],
        ),
      ),
    );
  }
}
