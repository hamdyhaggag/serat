import 'package:flutter/material.dart';
import 'package:serat/Presentation/Config/constants/colors.dart';

/// A widget that displays a loading indicator.
class LoadingIndicator extends StatelessWidget {
  /// Creates a new [LoadingIndicator] instance.
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: AppColors.primaryColor,
      ),
    );
  }
}
