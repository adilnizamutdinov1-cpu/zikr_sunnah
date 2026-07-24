// Progress Ring Widget

import 'package:flutter/material.dart';
import 'dart:math' as math;

class ProgressRing extends StatelessWidget {
  final double progress;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;
  final AnimationController? animationController;
  final bool showWarning;
  final Color warningColor;
  final Duration animationDuration;

  const ProgressRing({
    super.key,
    required this.progress,
    this.strokeWidth = 12,
    required this.backgroundColor,
    required this.progressColor,
    this.animationController,
    this.showWarning = false,
    this.warningColor = Colors.amber,
    this.animationDuration = const Duration(milliseconds: 500),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController ?? _dummyAnimation,
      builder: (context, child) {
        final animatedProgress = animationController != null
            ? animationController!.value * progress
            : progress;

        return CustomPaint(
          painter: _ProgressRingPainter(
            progress: animatedProgress,
            strokeWidth: strokeWidth,
            backgroundColor: backgroundColor,
            progressColor: progressColor,
            showWarning: showWarning,
            warningColor: warningColor,
            warningAnimation: animationController?.value ?? 0,
          ),
        );
      },
    );
  }

  static final _dummyAnimation = AlwaysStoppedAnimation(1.0);
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;
  final bool showWarning;
  final Color warningColor;
  final double warningAnimation;

  _ProgressRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.progressColor,
    this.showWarning = false,
    required this.warningColor,
    required this.warningAnimation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background ring
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress ring
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );
    }

    // Warning ring (pulsing)
    if (showWarning && progress < 1.0) {
      final warningPaint = Paint()
        ..color = warningColor.withValues(alpha: 0.3 + 0.3 * (1 + math.sin(warningAnimation * 4 * math.pi)) / 2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 4
        ..strokeCap = StrokeCap.round;

      canvas.drawCircle(center, radius + strokeWidth / 2 + 2, warningPaint);
    }

    // Completion glow
    if (progress >= 1.0) {
      final glowPaint = Paint()
        ..color = progressColor.withValues(alpha: 0.2 * (1 + math.sin(warningAnimation * 6 * math.pi)) / 2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 8
        ..strokeCap = StrokeCap.round;

      canvas.drawCircle(center, radius + strokeWidth / 2 + 4, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.showWarning != showWarning ||
           oldDelegate.warningAnimation != warningAnimation;
  }
}

// Progress Ring with Animation
class AnimatedProgressRing extends StatefulWidget {
  final double progress;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;
  final bool showWarning;
  final Color warningColor;
  final Duration duration;
  final Curve curve;

  const AnimatedProgressRing({
    super.key,
    required this.progress,
    this.strokeWidth = 12,
    required this.backgroundColor,
    required this.progressColor,
    this.showWarning = false,
    this.warningColor = Colors.amber,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<AnimatedProgressRing> createState() => _AnimatedProgressRingState();
}

class _AnimatedProgressRingState extends State<AnimatedProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  double _previousProgress = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0,
      end: widget.progress,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _previousProgress = _progressAnimation.value;
      _progressAnimation = Tween<double>(
        begin: _previousProgress,
        end: widget.progress,
      ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: _ProgressRingPainter(
            progress: _progressAnimation.value,
            strokeWidth: widget.strokeWidth,
            backgroundColor: widget.backgroundColor,
            progressColor: widget.progressColor,
            showWarning: widget.showWarning,
            warningColor: widget.warningColor,
            warningAnimation: _controller.value,
          ),
        );
      },
    );
  }
}