import 'dart:math';
import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class IslamicLoadingIndicator extends StatefulWidget {
  final double size;
  final Color? color;

  const IslamicLoadingIndicator({super.key, this.size = 50.0, this.color});

  @override
  State<IslamicLoadingIndicator> createState() =>
      _IslamicLoadingIndicatorState();
}

class _IslamicLoadingIndicatorState extends State<IslamicLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final color =
        widget.color ??
        (isDarkMode ? const Color(0xff0c8ee1) : AppColors.primaryColor);

    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Crescent Moon
            Transform.rotate(
              angle: _rotationAnimation.value,
              child: CustomPaint(
                size: Size(widget.size, widget.size),
                painter: CrescentMoonPainter(color: color),
              ),
            ),
            // Stars
            ...List.generate(3, (index) {
              final starAngle = (2 * pi * index / 3) + _rotationAnimation.value;
              final starDistance = widget.size * 0.4;
              return Positioned(
                left: widget.size / 2 + cos(starAngle) * starDistance - 4,
                top: widget.size / 2 + sin(starAngle) * starDistance - 4,
                child: Transform.rotate(
                  angle: _rotationAnimation.value * 2,
                  child: Icon(Icons.star, size: 8, color: color),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

class CrescentMoonPainter extends CustomPainter {
  final Color color;

  CrescentMoonPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;

    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;

    // Draw the outer arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      pi,
      false,
      paint,
    );

    // Draw the inner arc to create the crescent shape
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.7),
      pi / 2,
      pi,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
