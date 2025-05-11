import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../business_logic/cubit/azkar_cubit.dart';
import '../../../business_logic/cubit/azkar_state.dart';

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
    return BlocBuilder<AzkarCubit, AzkarState>(
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            azkar.length,
            (index) => Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    index == state.currentIndex
                        ? Colors.white
                        : Colors.white.withOpacity(0.3),
              ),
            ),
          ),
        );
      },
    );
  }
}
