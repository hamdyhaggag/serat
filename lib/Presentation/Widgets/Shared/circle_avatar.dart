import 'package:flutter/material.dart';
import 'package:serat/Business_Logic/Cubit/counter_cubit.dart';
import 'package:serat/imports.dart';

class CircleAvatarWidget extends StatelessWidget {
  const CircleAvatarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CounterCubit, CounterState>(
      listener: (context, state) {},
      builder: (context, state) {
        var counterCubit = CounterCubit.get(context);
        return GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder:
                  (BuildContext context) => AppDialog(
                    content: 'هل تود تغيير عدد التسبيح ؟',
                    okAction: AppDialogAction(
                      title: 'نعم',
                      onTap: () {
                        counterCubit.changeMaxCounter(33);
                        Navigator.of(context).pop();
                      },
                    ),
                    cancelAction: AppDialogAction(
                      title: 'لا',
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
            );
          },
          child: CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primaryColor,
            child: AppText(
              '${counterCubit.maxCounter}',
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        );
      },
    );
  }
}
