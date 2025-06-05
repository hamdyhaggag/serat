import 'package:flutter/material.dart';
import 'dart:math' show pi, cos, sin;

class ModernPatternPainter extends CustomPainter {
  final Color color;

  ModernPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw hexagon pattern
    final hexSize = size.width / 8;
    for (int i = -2; i < 10; i++) {
      for (int j = -2; j < 6; j++) {
        final centerX = i * hexSize * 1.5;
        final centerY = j * hexSize * 1.732 + (i % 2) * hexSize * 0.866;

        _drawHexagon(canvas, Offset(centerX, centerY), hexSize * 0.8, paint);
      }
    }

    // Draw subtle dots
    paint.style = PaintingStyle.fill;
    for (int i = 0; i < 30; i++) {
      final x = size.width * (i + 1) / 31;
      final y = size.height * 0.2;
      canvas.drawCircle(Offset(x, y), 1, paint);
    }
  }

  void _drawHexagon(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = i * pi / 3;
      final x = center.dx + size * cos(angle);
      final y = center.dy + size * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 