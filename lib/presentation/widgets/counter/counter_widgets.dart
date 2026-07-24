// Counter Widgets

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

// ============================================
// PROGRESS RING
// ============================================
class ProgressRing extends StatefulWidget {
  final double progress;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;
  final AnimationController? animationController;
  final bool showWarning;
  final Color? warningColor;
  final Duration animationDuration;

  const ProgressRing({
    super.key,
    required this.progress,
    this.strokeWidth = 12,
    required this.backgroundColor,
    required this.progressColor,
    this.animationController,
    this.showWarning = false,
    this.warningColor,
    this.animationDuration = const Duration(milliseconds: 500),
  });

  @override
  State<ProgressRing> createState() => _ProgressRingState();
}

class _ProgressRingState extends State<ProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _internalController;
  late Animation<double> _progressAnimation;
  
  @override
  void initState() {
    super.initState();
    _internalController = widget.animationController ?? 
      AnimationController(vsync: this, duration: widget.animationDuration);
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _internalController,
      curve: Curves.easeOutCubic,
    ));
    
    _internalController.forward();
  }
  
  @override
  void didUpdateWidget(covariant ProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: oldWidget.progress,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _internalController,
        curve: Curves.easeOutCubic,
      ));
      _internalController.forward(from: 0.0);
    }
  }
  
  @override
  void dispose() {
    if (widget.animationController == null) {
      _internalController.dispose();
    }
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
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;
  final bool showWarning;
  final Color? warningColor;

  _ProgressRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.progressColor,
    this.showWarning = false,
    this.warningColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    
    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    
    canvas.drawCircle(center, radius, backgroundPaint);
    
    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = showWarning && warningColor != null ? warningColor! : progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      
      final sweepAngle = 2 * 3.14159 * progress.clamp(0.0, 1.0);
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -3.14159 / 2, // Start from top
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.strokeWidth != strokeWidth ||
           oldDelegate.backgroundColor != backgroundColor ||
           oldDelegate.progressColor != progressColor ||
           oldDelegate.showWarning != showWarning ||
           oldDelegate.warningColor != warningColor;
  }
}

// ============================================
// ZIKR HEADER
// ============================================
class ZikrHeader extends StatelessWidget {
  final Zikr zikr;
  final bool showWarning;
  final String? warningText;

  const ZikrHeader({
    super.key,
    required this.zikr,
    this.showWarning = false,
    this.warningText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final zikrColor = Color(zikr.colorValue);
    
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Column(
        children: [
          // Warning banner
          if (showWarning && warningText != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.tertiary.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 20,
                    color: colorScheme.tertiary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    warningText!,
                    style: AppTextStyles.bodyMedium(colorScheme.tertiary).copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ).animate().fadeIn().shimmer(duration: 1500.ms),
          
          // Arabic text
          Text(
            zikr.arabicText,
            style: AppTextStyles.arabicLarge(colorScheme.onSurface).copyWith(
              color: zikrColor,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),
          
          const SizedBox(height: 8),
          
          // Transliteration
          Text(
            zikr.transliteration,
            style: AppTextStyles.bodyLarge(colorScheme.onSurfaceVariant).copyWith(
              fontStyle: FontStyle.italic,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
          
          const SizedBox(height: 4),
          
          // Translation
          Text(
            '"${zikr.translation}"',
            style: AppTextStyles.bodyMedium(colorScheme.onSurfaceVariant).copyWith(
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 150.ms, duration: 300.ms),
        ],
      ),
    );
  }
}

// ============================================
// COUNTER DISPLAY
// ============================================
class CounterDisplay extends StatelessWidget {
  final String count;
  final TextStyle? style;
  final Duration animationDuration;

  const CounterDisplay({
    super.key,
    required this.count,
    this.style,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: style ?? Theme.of(context).textTheme.displayLarge!,
      child: AnimatedSwitcher(
        duration: animationDuration,
        transitionBuilder: (child, animation) {
          return ScaleTransition(
            scale: animation,
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        child: Text(
          count,
          key: ValueKey(count),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// ============================================
// INCREMENT BUTTONS ROW
// ============================================
class IncrementButtons extends StatelessWidget {
  final VoidCallback onIncrement1;
  final VoidCallback onIncrement10;
  final VoidCallback onIncrement100;
  final VoidCallback onIncrement1000;
  final VoidCallback onSetExact;
  final Color accentColor;

  const IncrementButtons({
    super.key,
    required this.onIncrement1,
    required this.onIncrement10,
    required this.onIncrement100,
    required this.onIncrement1000,
    required this.onSetExact,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        _IncrementButton(
          label: '+1',
          onTap: onIncrement1,
          color: accentColor,
        ),
        _IncrementButton(
          label: '+10',
          onTap: onIncrement10,
          color: accentColor,
        ),
        _IncrementButton(
          label: '+100',
          onTap: onIncrement100,
          color: accentColor,
        ),
        _IncrementButton(
          label: '+1000',
          onTap: onIncrement1000,
          color: accentColor,
        ),
        _IncrementButton(
          label: 'Точное',
          onTap: onSetExact,
          color: theme.colorScheme.primary,
          isOutlined: true,
        ),
      ],
    );
  }
}

class _IncrementButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;
  final bool isOutlined;

  const _IncrementButton({
    required this.label,
    required this.onTap,
    required this.color,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isOutlined ? Colors.transparent : color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: isOutlined ? 1.0 : 0.3),
            width: isOutlined ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelLarge(isOutlined ? color : color).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ============================================
// TARGET SELECTOR
// ============================================
class TargetSelector extends StatelessWidget {
  final int currentTarget;
  final Function(int) onTargetChanged;
  final List<int> defaultTargets;
  final Color accentColor;

  const TargetSelector({
    super.key,
    required this.currentTarget,
    required this.onTargetChanged,
    required this.defaultTargets,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Цель',
          style: AppTextStyles.titleMedium(theme.colorScheme.onSurface),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ...defaultTargets.map((target) => _TargetChip(
              label: target.toString(),
              isSelected: currentTarget == target,
              onTap: () => onTargetChanged(target),
              color: accentColor,
            )),
            _TargetChip(
              label: 'Своя',
              isSelected: !defaultTargets.contains(currentTarget),
              onTap: () => _showCustomTargetDialog(context),
              color: theme.colorScheme.primary,
              isCustom: true,
            ),
          ],
        ),
      ],
    );
  }

  void _showCustomTargetDialog(BuildContext context) {
    final controller = TextEditingController(text: currentTarget.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Своя цель'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Введите число',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              final value = int.tryParse(controller.text) ?? currentTarget;
              onTargetChanged(value.clamp(1, 999999));
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _TargetChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;
  final bool isCustom;

  const _TargetChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.color,
    this.isCustom = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected 
            ? color 
            : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : theme.colorScheme.outline,
            width: isSelected ? 0 : 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isCustom) ...[
              Icon(
                Icons.edit_rounded,
                size: 16,
                color: isSelected ? theme.colorScheme.onPrimary : color,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppTextStyles.labelMedium(
                isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}