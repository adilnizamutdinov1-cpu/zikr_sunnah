import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/models/models.dart';
import '../../core/theme/theme.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/storage/storage.dart';
import '../widgets/common/common_widgets.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(title: Text(l.settings)),
      body: settingsAsync.when(
        loading: () => const LoadingState(message: 'Загрузка...'),
        error: (e, _) => ErrorState(message: e.toString(), onRetry: () => ref.invalidate(settingsProvider)),
        data: (settings) => _buildSettingsList(context, settings),
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context, AppSettings settings) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        // Theme Section
        _buildSectionHeader(context, 'Тема', Icons.palette_rounded),
        _buildThemeSelector(context, settings),

        const SizedBox(height: 24),

        // Appearance
        _buildSectionHeader(context, 'Внешний вид', Icons.brush_rounded),

        const SizedBox(height: 24),

        // Haptics
        _buildSectionHeader(context, 'Вибрация', Icons.vibration_rounded),
        _buildSwitchTile(
          context,
          title: 'Включить вибрацию',
          subtitle: 'Вибрация при нажатиях и достижении целей',
          value: settings.hapticsEnabled,
          onChanged: (v) => _updateSettings(settings.copyWith(hapticsEnabled: v)),
        ),
        if (settings.hapticsEnabled)
          _buildSelectorTile<HapticIntensity>(
            context,
            title: 'Сила вибрации',
            value: settings.hapticIntensity,
            options: HapticIntensity.values,
            labels: {
              HapticIntensity.light: 'Лёгкая',
              HapticIntensity.medium: 'Средняя',
              HapticIntensity.heavy: 'Сильная',
            },
            onChanged: (v) => _updateSettings(settings.copyWith(hapticIntensity: v)),
          ),

        const SizedBox(height: 24),

        // Counter Behavior
        _buildSectionHeader(context, 'Поведение счётчика', Icons.touch_app_rounded),
        _buildSelectorTile<int>(
          context,
          title: 'Предупреждение за % до цели',
          value: settings.warningThresholdPercent,
          options: [1, 3, 5, 10, 15],
          labels: {1: '1%', 3: '3%', 5: '5%', 10: '10%', 15: '15%'},
          onChanged: (v) => _updateSettings(settings.copyWith(warningThresholdPercent: v)),
        ),

        const SizedBox(height: 24),

        // Number Format
        _buildSectionHeader(context, 'Формат чисел', Icons.format_list_numbered_rounded),
        _buildSelectorTile<NumberFormatType>(
          context,
          title: 'Формат чисел',
          value: settings.numberFormat,
          options: NumberFormatType.values,
          labels: {
            NumberFormatType.space: 'С пробелами (1 000)',
            NumberFormatType.comma: 'С запятыми (1,000)',
            NumberFormatType.plain: 'Без разделителей (1000)',
          },
          onChanged: (v) => _updateSettings(settings.copyWith(numberFormat: v)),
        ),

        const SizedBox(height: 24),

        // Language
        _buildSectionHeader(context, 'Язык', Icons.language_rounded),
        _buildSelectorTile<String>(
          context,
          title: 'Язык',
          value: settings.languageCode,
          options: ['ru', 'uk', 'en', 'ar'],
          labels: {
            'ru': 'Русский',
            'uk': 'Українська',
            'en': 'English',
            'ar': 'العربية',
          },
          onChanged: (v) => _updateSettings(settings.copyWith(languageCode: v)),
        ),

        const SizedBox(height: 24),

        // Backup
        _buildSectionHeader(context, 'Резервное копирование', Icons.backup_rounded),
        _buildActionTile(
          context,
          icon: Icons.download_rounded,
          title: 'Экспорт резервной копии',
          subtitle: 'Сохранить все данные в файл',
          onTap: _exportBackup,
          color: cs.primary,
        ),
        _buildActionTile(
          context,
          icon: Icons.upload_rounded,
          title: 'Импорт резервной копии',
          subtitle: 'Восстановить данные из файла',
          onTap: _importBackup,
          color: cs.secondary,
        ),

        const SizedBox(height: 24),

        // Danger Zone
        _buildSectionHeader(context, 'Опасная зона', Icons.warning_amber_rounded,
          headerColor: cs.error),
        _buildActionTile(
          context,
          icon: Icons.delete_forever_rounded,
          title: 'Очистить все данные',
          subtitle: 'Удалить все зикры, статистику и настройки',
          onTap: _clearAllData,
          color: cs.error,
          isDestructive: true,
        ),

        const SizedBox(height: 24),

        // About
        _buildSectionHeader(context, 'О приложении', Icons.info_rounded),
        _buildAboutTile(context),

        const SizedBox(height: 16),

        // Privacy notice
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(Icons.privacy_tip_rounded, color: cs.primary, size: 20),
                const SizedBox(width: 8),
                Text('Приватность', style: theme.textTheme.titleSmall?.copyWith(color: cs.primary, fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(height: 8),
              Text('Приложение работает полностью офлайн. Никакой рекламы, авторизации или аналитики.',
                style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
              const SizedBox(height: 4),
              Text('Все данные хранятся только на вашем устройстве.',
                style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon, {Color? headerColor}) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final color = headerColor ?? cs.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Row(children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 10),
        Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: color)),
      ]),
    );
  }

  Widget _buildThemeSelector(BuildContext context, AppSettings settings) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final currentMode = settings.themeMode;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline.withValues(alpha: 0.1)),
      ),
      child: Column(children: [
        _buildThemeOption(context, mode: AppThemeMode.light, currentMode: currentMode, icon: Icons.light_mode_rounded, title: 'Светлая', subtitle: 'Всегда светлая тема', onTap: () => _updateSettings(settings.copyWith(themeMode: AppThemeMode.light))),
        Divider(height: 1, color: cs.outline.withValues(alpha: 0.1)),
        _buildThemeOption(context, mode: AppThemeMode.dark, currentMode: currentMode, icon: Icons.dark_mode_rounded, title: 'Тёмная', subtitle: 'Всегда тёмная тема', onTap: () => _updateSettings(settings.copyWith(themeMode: AppThemeMode.dark))),
        Divider(height: 1, color: cs.outline.withValues(alpha: 0.1)),
        _buildThemeOption(context, mode: AppThemeMode.system, currentMode: currentMode, icon: Icons.settings_system_daydream_rounded, title: 'По системе', subtitle: 'Следовать настройкам системы', onTap: () => _updateSettings(settings.copyWith(themeMode: AppThemeMode.system))),
      ]),
    );
  }

  Widget _buildThemeOption(BuildContext context, {required AppThemeMode mode, required AppThemeMode currentMode, required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isSelected = currentMode == mode;

    return ListTile(
      leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: isSelected ? cs.primary.withValues(alpha: 0.2) : cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: isSelected ? cs.primary : cs.onSurfaceVariant, size: 22)),
      title: Text(title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500, color: isSelected ? cs.primary : cs.onSurface)),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
      trailing: isSelected ? Icon(Icons.check_circle_rounded, color: cs.primary, size: 24) : null,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildSwitchTile(BuildContext context, {required String title, required String subtitle, required bool value, required ValueChanged<bool> onChanged}) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(margin: const EdgeInsets.only(bottom: 8), decoration: BoxDecoration(color: cs.surfaceContainerHighest.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(12), border: Border.all(color: cs.outline.withValues(alpha: 0.1))), child: SwitchListTile(title: Text(title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500, color: cs.onSurface)), subtitle: Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)), value: value, onChanged: onChanged, activeColor: cs.primary, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4)));
  }

  Widget _buildSelectorTile<T>(BuildContext context, {required String title, required T value, required List<T> options, required Map<T, String> labels, required ValueChanged<T> onChanged}) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(margin: const EdgeInsets.only(bottom: 8), decoration: BoxDecoration(color: cs.surfaceContainerHighest.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(12), border: Border.all(color: cs.outline.withValues(alpha: 0.1))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 8), child: Text(title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500, color: cs.onSurface))),
      Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 12), child: Wrap(spacing: 8, runSpacing: 8, children: options.map((opt) {
        final isSelected = opt == value;
        return ChoiceChip(label: Text(labels[opt] ?? opt.toString()), selected: isSelected, onSelected: (_) => _updateSettings(settings.copyWith() as dynamic), selectedColor: cs.primary, labelStyle: theme.textTheme.labelMedium?.copyWith(color: isSelected ? cs.onPrimary : cs.onSurface, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400), backgroundColor: cs.surface, side: BorderSide(color: isSelected ? cs.primary : cs.outline.withValues(alpha: 0.3)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)));
      }).toList())),
    ]));
  }

  Widget _buildActionTile(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap, required Color color, bool isDestructive = false}) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(margin: const EdgeInsets.only(bottom: 8), decoration: BoxDecoration(color: isDestructive ? color.withValues(alpha: 0.1) : cs.surfaceContainerHighest.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(12), border: Border.all(color: isDestructive ? color.withValues(alpha: 0.3) : cs.outline.withValues(alpha: 0.1))), child: ListTile(leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: isDestructive ? color.withValues(alpha: 0.2) : color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: isDestructive ? color : cs.primary, size: 22)), title: Text(title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500, color: isDestructive ? color : cs.onSurface)), subtitle: Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)), trailing: Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant), onTap: onTap, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4)));
  }

  Widget _buildAboutTile(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l = context.l10n;
    return Container(margin: const EdgeInsets.only(bottom: 8), decoration: BoxDecoration(color: cs.surfaceContainerHighest.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(12), border: Border.all(color: cs.outline.withValues(alpha: 0.1))), child: Column(children: [
      ListTile(leading: Container(width: 48, height: 48, decoration: BoxDecoration(color: cs.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.mosque_rounded, color: cs.primary, size: 28)), title: Text(l.appTitle, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)), subtitle: Text('Версия 1.0.0', style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant))),
      Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), child: Row(children: [Expanded(child: OutlinedButton.icon(onPressed: () => showLicensePage(context: context, applicationName: l.appTitle, applicationVersion: '1.0.0', applicationIcon: const Icon(Icons.mosque_rounded, size: 48, color: Color(0xFF006D5B)), applicationLegalese: 'Приложение работает полностью офлайн. Никакой рекламы, авторизации или аналитики.'), icon: const Icon(Icons.article_rounded, size: 18), label: const Text('Лицензии')))])),
    ]));
  }

  void _updateSettings(AppSettings newSettings) {
    ref.read(settingsProvider.notifier).updateSettings(newSettings);
  }

  Future<void> _exportBackup() async {
    try {
      final repo = ref.read(storageRepositoryProvider) as HiveStorageRepository;
      await repo.snapshot(); // triggers download via share
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Резервная копия сохранена'), behavior: SnackBarBehavior.floating));
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e'), backgroundColor: Theme.of(context).colorScheme.error, behavior: SnackBarBehavior.floating)); }
  }

  Future<void> _importBackup() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json'], dialogTitle: 'Выберите файл резервной копии');
      if (result != null && result.files.single.path != null) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Резервная копия восстановлена'), behavior: SnackBarBehavior.floating));
      }
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e'), backgroundColor: Theme.of(context).colorScheme.error, behavior: SnackBarBehavior.floating)); }
  }

  Future<void> _clearAllData() async {
    final confirmed = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('Удалить все данные?'), content: const Text('Это действие нельзя отменить. Будут удалены все зикры, статистика и настройки.'), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Отмена')), FilledButton(onPressed: () => Navigator.pop(c, true), style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error), child: const Text('Подтвердить'))]));
    if (confirmed == true && mounted) {
      final repo = ref.read(storageRepositoryProvider);
      await repo.clearAllData();
      ref.invalidate(zikrListProvider); ref.invalidate(settingsProvider); ref.invalidate(activeZikrIdProvider);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Все данные удалены'), behavior: SnackBarBehavior.floating));
    }
  }
}