// Zikrs Screen Widgets

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/models/zikr_models.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/storage/storage_repository_impl.dart';
import '../widgets/common/common_widgets.dart';

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
    final colorScheme = theme.colorScheme;
    final zikrColor = Color(zikr.colorValue);
    final progress = zikr.progress;
    final isTargetReached = zikr.isTargetReached;
    final showWarning = zikr.showWarning;

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
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isSunnah
                                    ? colorScheme.primary.withValues(alpha: 0.15)
                                    : colorScheme.secondary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isSunnah ? 'Сунна' : 'Свой',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: isSunnah
                                      ? colorScheme.primary
                                      : colorScheme.secondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (zikr.source != null) ...[
                              const SizedBox(width: 8),
                              Icon(
                                Icons.info_outline_rounded,
                                size: 14,
                                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
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
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isTargetReached
                            ? zikrColor
                            : colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      zikr.formattedCurrentCount,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isTargetReached ? zikrColor : colorScheme.onSurface,
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
                  color: colorScheme.onSurfaceVariant,
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
                          backgroundColor: colorScheme.outline.withValues(alpha: 0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isTargetReached ? zikrColor : colorScheme.primary,
                          ),
                        ),
                        if (zikr.targetCount > 0)
                          Text(
                            '${(progress * 100).round()}%',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
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
                                color: colorScheme.onSurface,
                              ),
                            ),
                            if (showWarning) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: colorScheme.tertiary.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Осталось ${zikr.remainingToTarget}',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colorScheme.tertiary,
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
                            color: colorScheme.onSurfaceVariant,
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
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.auto_stories_rounded,
                        size: 18,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Источник: ${zikr.source}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
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

// ============================================
// ADD/EDIT ZIKR DIALOG
// ============================================
class AddZikrDialog extends ConsumerStatefulWidget {
  final Zikr? existingZikr;

  const AddZikrDialog({super.key, this.existingZikr});

  @override
  ConsumerState<AddZikrDialog> createState() => _AddZikrDialogState();
}

class _AddZikrDialogState extends ConsumerState<AddZikrDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _arabicController;
  late TextEditingController _transliterationController;
  late TextEditingController _translationController;
  late TextEditingController _sourceController;
  late TextEditingController _targetController;
  
  late int _selectedColor;
  late int _targetCount;
  final List<int> _presetTargets = [33, 100, 1000];
  final List<Color> _colorOptions = [
    const Color(0xFF006D5B), // Teal
    const Color(0xFF007B7F), // Cyan
    const Color(0xFF00838F), // Light Teal
    const Color(0xFF006064), // Dark Teal
    const Color(0xFF00796B), // Green Teal
    const Color(0xFF00695C), // Dark Green
    const Color(0xFF004D40), // Very Dark Teal
    const Color(0xFF1B5E20), // Dark Green
    const Color(0xFF3E2723), // Brown
    const Color(0xFF4E342E), // Dark Brown
  ];

  @override
  void initState() {
    super.initState();
    final zikr = widget.existingZikr;
    _nameController = TextEditingController(text: zikr?.name ?? '');
    _arabicController = TextEditingController(text: zikr?.arabicText ?? '');
    _transliterationController = TextEditingController(text: zikr?.transliteration ?? '');
    _translationController = TextEditingController(text: zikr?.translation ?? '');
    _sourceController = TextEditingController(text: zikr?.source ?? '');
    _targetController = TextEditingController(text: zikr?.targetCount.toString() ?? '100');
    _selectedColor = zikr?.colorValue ?? _colorOptions.first.value;
    _targetCount = zikr?.targetCount ?? 100;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _arabicController.dispose();
    _transliterationController.dispose();
    _translationController.dispose();
    _sourceController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final isEditing = widget.existingZikr != null;

    return AlertDialog(
      title: Text(isEditing ? l10n.editZikr : l10n.addZikr),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Name
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.name,
                    hintText: 'Например: Мои утренние азкары',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Введите название';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Arabic text
                TextFormField(
                  controller: _arabicController,
                  decoration: InputDecoration(
                    labelText: l10n.arabicText,
                    hintText: 'سُبْحَانَ اللَّهِ',
                    hintTextDirection: TextDirection.rtl,
                  ),
                  textDirection: TextDirection.rtl,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Введите арабский текст';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Transliteration
                TextFormField(
                  controller: _transliterationController,
                  decoration: InputDecoration(
                    labelText: l10n.transliteration,
                    hintText: 'Subhanallah',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Введите транскрипцию';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Translation
                TextFormField(
                  controller: _translationController,
                  decoration: InputDecoration(
                    labelText: l10n.translation,
                    hintText: 'Пречистен Аллах',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Введите перевод';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Source (optional)
                TextFormField(
                  controller: _sourceController,
                  decoration: InputDecoration(
                    labelText: l10n.source,
                    hintText: l10n.sourcePlaceholder,
                  ),
                ),

                const SizedBox(height: 16),

                // Color picker
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.color, style: theme.textTheme.labelLarge),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _colorOptions.map((color) => GestureDetector(
                        onTap: () => setState(() => _selectedColor = color.value),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _selectedColor == color.value
                                  ? colorScheme.onSurface
                                  : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: _selectedColor == color.value
                                ? [BoxShadow(
                                    color: color.withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  )]
                                : null,
                          ),
                        ),
                      )).toList(),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Target
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.target, style: theme.textTheme.labelLarge),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ..._presetTargets.map((target) => ChoiceChip(
                          label: Text(target.toString()),
                          selected: _targetCount == target,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _targetCount = target;
                                _targetController.text = target.toString();
                              });
                            }
                          },
                        )),
                        // Custom target
                        SizedBox(
                          width: 80,
                          child: TextFormField(
                            controller: _targetController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: l10n.customTarget,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            onChanged: (value) {
                              _targetCount = int.tryParse(value) ?? _targetCount;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _saveZikr,
          child: Text(isEditing ? l10n.confirm : l10n.addZikr),
        ),
      ],
    );
  }

  void _saveZikr() async {
    if (!_formKey.currentState!.validate()) return;

    final repo = ref.read(storageRepositoryProvider);
    await repo.initialize();

    final now = DateTime.now();
    final zikr = Zikr(
      id: widget.existingZikr?.id ?? 'custom_${now.millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      arabicText: _arabicController.text.trim(),
      transliteration: _transliterationController.text.trim(),
      translation: _translationController.text.trim(),
      targetCount: _targetCount,
      currentCount: widget.existingZikr?.currentCount ?? 0,
      totalCount: widget.existingZikr?.totalCount ?? 0,
      practiceTimeSeconds: widget.existingZikr?.practiceTimeSeconds ?? 0,
      colorValue: _selectedColor,
      category: ZikrCategory.custom,
      source: _sourceController.text.trim().isEmpty ? null : _sourceController.text.trim(),
      createdAt: widget.existingZikr?.createdAt ?? now,
      updatedAt: now,
      warningThreshold: null,
      autoResetOnTarget: false,
    );

    await repo.saveZikr(zikr);
    ref.invalidate(allZikrsStreamProvider);

    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.existingZikr != null
              ? '${zikr.name} ${context.l10n.counter} обновлён'
              : '${context.l10n.customZikr} "${zikr.name}" создан'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}