// Общие виджеты и утилиты.

import 'package:flutter/material.dart';

import '../../../core/models/models.dart';
import '../../../core/theme/theme.dart';
import '../../../core/l10n/app_localizations.dart';

/// Раздел экрана с заголовком.
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const SectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.darkTextPrimary,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Пустое состояние.
class EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  const EmptyState({super.key, required this.message, this.icon = Icons.favorite_border});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: AppColors.darkTextMuted),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.darkTextSecondary,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Форматирование числа согласно настройке.
String formatNumber(int value, NumberFormatType type) {
  String sep;
  switch (type) {
    case NumberFormatType.space:
      sep = '\u00A0'; // неразрывный пробел
      break;
    case NumberFormatType.comma:
      sep = ',';
      break;
    case NumberFormatType.plain:
      return value.toString();
  }
  final str = value.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) buffer.write(sep);
    buffer.write(str[i]);
  }
  return buffer.toString();
}

/// Подтверждение действия. Сброс всегда требует подтверждения.
Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String? confirmLabel,
  bool destructive = false,
}) async {
  final l = context.l10n;
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(title, style: const TextStyle(color: AppColors.darkTextPrimary)),
      content: Text(message,
          style: const TextStyle(color: AppColors.darkTextSecondary, height: 1.5)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l.cancel, style: const TextStyle(color: AppColors.darkTextMuted)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(
            confirmLabel ?? l.confirm,
            style: TextStyle(
              color: destructive ? const Color(0xFFE07A5F) : AppColors.islamicGold,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
  return result ?? false;
}
