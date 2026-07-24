// Тонкое золотое кольцо прогресса (CustomPainter).
// Поддерживает «толчок вперёд» — короткое опережение реального прогресса
// при нажатии (анимация «живой тасбих»).

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class ProgressRing extends StatefulWidget {
  final double progress; // 0..1 реальный прогресс
  final double size;
  final double strokeWidth;
  final bool warning; // мерцание «почти у цели»
  final bool complete; // мягкое свечение при достижении

  const ProgressRing({
    super.key,
    required this.progress,
    this.size = 280,
    this.strokeWidth = 6,
    this.warning = false,
    this.complete = false,
  });

  @override
  State<ProgressRing> createState() => _ProgressRingState();
}

class _ProgressRingState extends State<ProgressRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bump;
  double _bumpValue = 0; // опережение 0..~0.05
  double _displayed = 0;

  @override
  void initState() {
    super.initState();
    _displayed = widget.progress.clamp(0.0, 1.0);
    _bump = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    )..addListener(() {
        setState(() {
          // вперёд — обратно (easeOut)
          _bumpValue = math.sin(_bump.value * math.pi) * 0.04;
          _displayed = (widget.progress + _bumpValue).clamp(0.0, 1.0);
        });
      });
  }

  @override
  void didUpdateWidget(covariant ProgressRing old) {
    super.didUpdateWidget(old);
    if ((old.progress - widget.progress).abs() > 0.0001) {
      _displayed = (widget.progress + _bumpValue).clamp(0.0, 1.0);
    }
  }

  /// Запустить короткий «толчок вперёд».
  void bump() => _bump.forward(from: 0);

  @override
  void dispose() {
    _bump.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: CustomPaint(
        painter: _RingPainter(
          progress: _displayed,
          strokeWidth: widget.strokeWidth,
          warning: widget.warning,
          complete: widget.complete,
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final bool warning;
  final bool complete;

  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.warning,
    required this.complete,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Фоновое кольцо
    final bgPaint = Paint()
      ..color = AppColors.darkSurfaceVariant
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    // Дуга прогресса
    const startAngle = -math.pi / 2;
    final sweep = 2 * math.pi * progress.clamp(0.0, 1.0);
    final arcPaint = Paint()
      ..color = AppColors.islamicGold
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    if (sweep > 0.001) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        false,
        arcPaint,
      );
    }

    // Мягкое свечение при достижении цели
    if (complete) {
      final glowPaint = Paint()
        ..color = AppColors.islamicGold.withValues(alpha: 0.12)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius - strokeWidth, glowPaint);
    }

    // Едва заметное мерцание при приближении к цели
    if (warning) {
      final warnPaint = Paint()
        ..color = AppColors.islamicGold.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth * 0.4
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        false,
        warnPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      progress != old.progress ||
      warning != old.warning ||
      complete != old.complete;
}
