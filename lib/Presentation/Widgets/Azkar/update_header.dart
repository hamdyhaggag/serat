import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class UpdateHeader extends StatelessWidget {
  final double screenWidth;

  const UpdateHeader({super.key, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AzkarCubit, AzkarState>(
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Display progress here
              AzkarProgressIndicator(
                screenWidth: screenWidth,
                screenHeight: MediaQuery.of(context).size.height,
                azkar: const [], // Pass the actual azkar list here
              ),
              // Display check icon state or other information
              // For example:
              Icon(
                state.completedCards.isNotEmpty
                    ? Icons.check_circle
                    : Icons.circle,
                color: Colors.green,
              ),
            ],
          ),
        );
      },
    );
  }
}
