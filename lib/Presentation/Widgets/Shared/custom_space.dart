import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'custom_folder_row.dart';

class CustomSpace extends StatelessWidget {
  const CustomSpace({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 10.0.h),
        Container(
          height: 2.h,
          width: 420.w,
          color: colorWithOpacity,
        ),
      ],
    );
  }
}
