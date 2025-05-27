import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serat/Business_Logic/Cubit/azkar_cubit.dart';
import 'package:serat/Business_Logic/Cubit/azkar_state.dart';
import 'package:serat/Presentation/Config/constants/colors.dart';

class AzkarProgressIndicator extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  final List<String> azkar;

  const AzkarProgressIndicator({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.azkar,
  });

  @override
  Widget build(BuildContext context) {
    // Set the total cards count in the state
    BlocProvider.of<AzkarCubit>(context).updateTotalCards(azkar.length);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
      child: BlocBuilder<AzkarCubit, AzkarState>(
        builder: (context, state) {
          final progress = state.progress;
          return Column(
            children: [
              Directionality(
                textDirection: TextDirection.rtl,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryColor,
                    ),
                    minHeight: screenWidth * 0.025,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                child: Text(
                  ' أكملت ${(progress * 100).round()}%',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : const Color(0xFF2D3436),
                    fontSize: screenWidth * 0.045,
                    fontFamily: 'DIN',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
