// Common Widgets

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ============================================
// ISLAMIC PATTERN BACKGROUND
// ============================================
class IslamicPatternBackground extends StatelessWidget {
  final Color color;
  final double opacity;
  final Widget? child;

  const IslamicPatternBackground({
    super.key,
    required this.color,
    required this.opacity,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base color
        Container(color: Theme.of(context).scaffoldBackgroundColor),
        
        // Pattern
        CustomPaint(
          painter: IslamicPatternPainter(
            color: color,
            opacity: opacity,
          ),
          size: Size.infinite,
        ),
        
        // Child content
        if (child != null) child!,
      ],
    );
  }
}

// ============================================
// ISLAMIC PATTERN PAINTER
// ============================================
class IslamicPatternPainter extends CustomPainter {
  final Color color;
  final double opacity;
  final double scale;

  IslamicPatternPainter({
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

    // Draw geometric pattern - simplified 8-pointed star grid
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
  bool shouldRepaint(covariant IslamicPatternPainter oldDelegate) {
    return oldDelegate.color != color ||
           oldDelegate.opacity != opacity ||
           oldDelegate.scale != scale;
  }
}

// ============================================
// RESPONSIVE LAYOUT HELPER
// ============================================
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 800 && desktop != null) {
          return desktop!;
        } else if (constraints.maxWidth >= 600 && tablet != null) {
          return tablet!;
        }
        return mobile;
      },
    );
  }
}

// ============================================
// ANIMATED CONTENT
// ============================================
class FadeInContent extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Curve curve;

  const FadeInContent({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOut,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: duration,
      curve: curve,
      child: child,
    );
  }
}

// ============================================
// SLIDE TRANSITION
// ============================================
class SlideFadeIn extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset begin;
  final Curve curve;

  const SlideFadeIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 400),
    this.begin = const Offset(0, 0.2),
    this.curve = Curves.easeOutCubic,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween(begin: begin, end: Offset.zero),
      duration: duration,
      curve: curve,
      builder: (context, offset, child) {
        return Transform.translate(
          offset: offset,
          child: Opacity(
            opacity: 1.0 - (offset.distance / begin.distance).clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

// ============================================
// SECTION HEADER
// ============================================
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  final EdgeInsetsGeometry padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleLarge(colorScheme.onSurface),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppTextStyles.bodyMedium(colorScheme.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

// ============================================
// EMPTY STATE
// ============================================
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;
  final double iconSize;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
    this.iconSize = 80,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: colorScheme.primary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 12),
              Text(
                message!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================
// LOADING STATE
// ============================================
class LoadingState extends StatelessWidget {
  final String? message;
  final double size;

  const LoadingState({
    super.key,
    this.message,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              color: colorScheme.primary,
              strokeWidth: 3,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================
// ERROR STATE
// ============================================
class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String? retryLabel;

  const ErrorState({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Ошибка',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(retryLabel ?? 'Повторить'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================
// DIVIDER WITH LABEL
// ============================================
class LabeledDivider extends StatelessWidget {
  final String label;
  final Color? color;
  final double thickness;
  final EdgeInsetsGeometry padding;

  const LabeledDivider({
    super.key,
    required this.label,
    this.color,
    this.thickness = 0.5,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dividerColor = color ?? theme.colorScheme.outline.withValues(alpha: 0.3);

    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(child: Divider(color: dividerColor, thickness: thickness)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Divider(color: dividerColor, thickness: thickness)),
        ],
      ),
    );
  }
}