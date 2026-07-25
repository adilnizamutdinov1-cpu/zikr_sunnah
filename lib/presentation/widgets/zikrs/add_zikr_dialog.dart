import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/models/models.dart';
import '../../core/theme/theme.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/storage/storage.dart';

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
  late int _step;
  final List<int> _presetTargets = [33, 100, 1000];
  final List<int> _presetSteps = [1, 2, 3, 5, 10];
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
    _step = zikr?.step ?? 1;
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
    final cs = theme.colorScheme;
    final l = context.l10n;
    final isEditing = widget.existingZikr != null;

    return AlertDialog(
      title: Text(isEditing ? l.editZikr : l.addZikr),
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
                    labelText: l.name,
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
                    labelText: l.arabicText,
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
                    labelText: l.transliteration,
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
                    labelText: l.translation,
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
                    labelText: l.source,
                    hintText: l.sourcePlaceholder,
                  ),
                ),

                const SizedBox(height: 16),

                // Color picker
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.color, style: theme.textTheme.labelLarge),
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
                                  ? cs.onSurface
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
                    Text(l.target, style: theme.textTheme.labelLarge),
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
                              labelText: l.customTarget,
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

                const SizedBox(height: 16),

                // Step
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Шаг увеличения', style: theme.textTheme.labelLarge),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _presetSteps.map((step) => ChoiceChip(
                        label: Text(step.toString()),
                        selected: _step == step,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _step = step);
                          }
                        },
                      )).toList(),
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
          child: Text(l.cancel),
        ),
        FilledButton(
          onPressed: _saveZikr,
          child: Text(isEditing ? l.confirm : l.addZikr),
        ),
      ],
    );
  }

  void _saveZikr() async {
    if (!_formKey.currentState!.validate()) return;

    final repo = ref.read(storageRepositoryProvider);
    await repo.init();

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
      category: ZikrCategory.personal,
      source: _sourceController.text.trim().isEmpty ? null : _sourceController.text.trim(),
      createdAt: widget.existingZikr?.createdAt ?? now,
      updatedAt: now,
      warningThreshold: null,
      autoResetOnTarget: false,
      step: _step,
      practiceTimeSeconds: widget.existingZikr?.practiceTimeSeconds ?? 0,
    );

    await repo.saveZikr(zikr);
    ref.invalidate(zikrListProvider);

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