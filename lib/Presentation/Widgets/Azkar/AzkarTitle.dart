import 'package:flutter/material.dart';

class AzkarTitle extends StatelessWidget {
  final double screenWidth;
  final String title;

  const AzkarTitle({super.key, required this.screenWidth, required this.title});

  @override
  Widget build(BuildContext context) {
    double threshold = 400.0;

    double fontSize =
        screenWidth > threshold ? screenWidth * 0.3 : screenWidth * 0.07;

    return Text(
      title,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        fontFamily: 'DIN',
      ),
    );
  }
}
