import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serat/Business_Logic/Cubit/azkar_cubit.dart';
import 'package:serat/Business_Logic/Cubit/azkar_state.dart';

class AzkarDotsIndicator extends StatelessWidget {
  final double screenWidth;
  final List<String> azkar;

  const AzkarDotsIndicator({
    super.key,
    required this.screenWidth,
    required this.azkar,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (index) {
          return BlocBuilder<AzkarCubit, AzkarState>(
            builder: (context, state) {
              int adjustedIndex = state.currentIndex % 4;
              bool isLastIndex = state.currentIndex == azkar.length - 1;

              return Container(
                margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                width: screenWidth * 0.02,
                height: screenWidth * 0.02,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      isLastIndex
                          ? Colors.grey.shade400
                          : (adjustedIndex == index
                              ? Colors.grey.shade400
                              : Colors.grey.shade700),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
