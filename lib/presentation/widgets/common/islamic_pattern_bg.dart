// Islamic Pattern Background Widget

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class IslamicPatternBackground extends StatelessWidget {
  final Color color;
  final double opacity;
  final double scale;
  final bool animate;

  const IslamicPatternBackground({
    super.key,
    required this.color,
    required this.opacity,
    this.scale = 1.0,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: animate ? opacity : opacity,
      duration: const Duration(milliseconds: 500),
      child: CustomPaint(
        painter: _IslamicPatternPainter(
          color: color,
          opacity: opacity,
          scale: scale,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _IslamicPatternPainter extends CustomPainter {
  final Color color;
  final double opacity;
  final double scale;

  _IslamicPatternPainter({
    required this.color,
    required this.opacity,
    this.scale = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8 * scale;

    final spacing = 80.0 * scale;
    final offset = spacing / 2;

    // Draw geometric pattern - 8-pointed stars in a grid
    for (double x = -spacing; x < size.width + spacing; x += spacing) {
      for (double y = -spacing; y < size.height + spacing; y += spacing) {
        final cx = x + ((y ~/ spacing) % 2 == 0 ? 0 : offset);
        _drawStar(canvas, paint, Offset(cx, y), 15 * scale);
      }
    }
  }

  void _drawStar(Canvas canvas, Paint paint, Offset center, double radius) {
    final path = Path();
    const int points = 8;
    final angleStep = 2 * 3.14159 / points;

    for (int i = 0; i < points; i++) {
      final angle = i * angleStep - 3.14159 / 2;
      final outerRadius = radius;
      final innerRadius = radius * 0.4;

      final outerX = center.dx + outerRadius * cos(angle);
      final outerY = center.dy + outerRadius * sin(angle);

      final innerAngle = angle + angleStep / 2;
      final innerX = center.dx + innerRadius * cos(innerAngle);
      final innerY = center.dy + innerRadius * sin(innerAngle);

      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }
      path.lineTo(innerX, innerY);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _IslamicPatternPainter oldDelegate) {
    return oldDelegate.color != color ||
           oldDelegate.opacity != opacity ||
           oldDelegate.scale != scale;
  }
}