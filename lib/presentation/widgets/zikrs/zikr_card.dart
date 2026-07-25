import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/models/models.dart';
import '../../core/theme/theme.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/storage/storage.dart';

class ZikrCard extends StatelessWidget {
  final Zikr zikr;
  final bool isSunnah;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const ZikrCard({
    super.key,
    required this.zikr,
    required this.isSunnah,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final zikrColor = Color(zikr.colorValue);
    final progress = zikr.progress;
    final isTargetReached = zikr.isTargetReached;
    final showWarning = zikr.showWarning(5); // default 5%

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  // Color indicator
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: zikrColor,
                      shape: BoxShape.circle,
                    ),
                  ).animate().fadeIn().scale(),
                  const SizedBox(width: 12),

                  // Name and category
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          zikr.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isSunnah
                                    ? cs.primary.withValues(alpha: 0.15)
                                    : cs.secondary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isSunnah ? 'Сунна' : 'Свой',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: isSunnah ? cs.primary : cs.secondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (zikr.source != null) ...[
                              const SizedBox(width: 8),
                              Icon(
                                Icons.info_outline_rounded,
                                size: 14,
                                color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Current count badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isTargetReached
                          ? zikrColor.withValues(alpha: 0.2)
                          : cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isTargetReached
                            ? zikrColor
                            : cs.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      zikr.formattedCurrentCount,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isTargetReached ? zikrColor : cs.onSurface,
                      ),
                    ),
                  ).animate().fadeIn().scale(),
                ],
              ),

              const SizedBox(height: 16),

              // Arabic text preview
              Text(
                zikr.arabicText,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: zikrColor,
                  fontFamily: 'NotoSansArabic',
                  height: 1.6,
                ),
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 8),

              // Translation
              Text(
                '"${zikr.translation}"',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ).animate().fadeIn(delay: 150.ms),

              const SizedBox(height: 16),

              // Progress section
              Row(
                children: [
                  // Progress ring
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          strokeWidth: 4,
                          backgroundColor: cs.outline.withValues(alpha: 0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isTargetReached ? zikrColor : theme.colorScheme.primary,
                          ),
                        ),
                        if (zikr.targetCount > 0)
                          Text(
                            '${(progress * 100).round()}%',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface,
                            ),
                          ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms).scale(),

                  const SizedBox(width: 16),

                  // Progress info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${zikr.formattedCurrentCount} / ${zikr.formattedTargetCount}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: cs.onSurface,
                              ),
                            ),
                            if (zikr.showWarning(5)) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.tertiary.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Осталось ${zikr.remainingToTarget}',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.tertiary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isTargetReached
                              ? 'Цель достигнута!'
                              : 'Всего: ${zikr.formattedTotalCount} • ${_formatDuration(zikr.practiceTimeSeconds)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Source info for Sunnah azkar
              if (zikr.source != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cs.outline.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.auto_stories_rounded, size: 18, color: cs.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Источник: ${zikr.source}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 250.ms),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '${seconds}с';
    if (seconds < 3600) return '${(seconds / 60).round()}м';
    return '${(seconds / 3600).toStringAsFixed(1)}ч';
  }
}