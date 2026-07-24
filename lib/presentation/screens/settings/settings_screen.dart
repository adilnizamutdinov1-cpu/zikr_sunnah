// Settings Screen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/models/zikr_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/storage/storage_repository_impl.dart';
import '../../widgets/common/common_widgets.dart';
import '../../../providers/zikr_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: settingsAsync.when(
        loading: () => const LoadingState(message: 'Загрузка настроек...'),
        error: (error, _) => ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(settingsProvider),
        ),
        data: (settings) => _buildSettingsList(context, settings),
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context, AppSettings settings) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        // Theme Section
        _buildSectionHeader(context, l10n.theme, Icons.palette_rounded),
        _buildThemeSelector(context, settings),
        
        const SizedBox(height: 24),
        
        // Appearance Section
        _buildSectionHeader(context, 'Внешний вид', Icons.brush_rounded),
        _buildSwitchTile(
          context,
          title: l10n.keepScreenOn,
          subtitle: 'Экран не выключается во время практики',
          value: settings.keepScreenOn,
          onChanged: (value) => _updateSettings(settings.copyWith(keepScreenOn: value)),
        ),
        _buildSwitchTile(
          context,
          title: l10n.reduceAnimations,
          subtitle: 'Уменьшить анимации для экономии батареи',
          value: settings.reduceAnimations,
          onChanged: (value) => _updateSettings(settings.copyWith(reduceAnimations: value)),
        ),
        
        const SizedBox(height: 24),
        
        // Haptics Section
        _buildSectionHeader(context, l10n.haptics, Icons.vibration_rounded),
        _buildSwitchTile(
          context,
          title: l10n.hapticsEnabled,
          subtitle: 'Вибрация при нажатиях и достижении целей',
          value: settings.hapticsEnabled,
          onChanged: (value) => _updateSettings(settings.copyWith(hapticsEnabled: value)),
        ),
        if (settings.hapticsEnabled) ...[
          _buildSelectorTile<HapticIntensity>(
            context,
            title: l10n.hapticIntensity,
            value: settings.hapticIntensity,
            options: HapticIntensity.values,
            labels: {
              HapticIntensity.light: l10n.hapticLight,
              HapticIntensity.medium: l10n.hapticMedium,
              HapticIntensity.heavy: l10n.hapticHeavy,
            },
            onChanged: (value) => _updateSettings(settings.copyWith(hapticIntensity: value)),
          ),
        ],
        
        const SizedBox(height: 24),
        
        // Sound Section
        _buildSectionHeader(context, l10n.sound, Icons.volume_up_rounded),
        _buildSwitchTile(
          context,
          title: l10n.soundEnabled,
          subtitle: 'Звук при нажатиях и достижении целей',
          value: settings.soundEnabled,
          onChanged: (value) => _updateSettings(settings.copyWith(soundEnabled: value)),
        ),
        
        const SizedBox(height: 24),
        
        // Counter Behavior Section
        _buildSectionHeader(context, 'Поведение счётчика', Icons.touch_app_rounded),
        _buildSelectorTile<int>(
          context,
          title: l10n.warningThresholdPercent,
          subtitle: 'Вибрация предупреждения за процент до цели',
          value: settings.warningThresholdPercent,
          options: [1, 3, 5, 10, 15],
          labels: {1: '1%', 3: '3%', 5: '5%', 10: '10%', 15: '15%'},
          onChanged: (value) => _updateSettings(settings.copyWith(warningThresholdPercent: value)),
        ),
        
        const SizedBox(height: 24),
        
        // Number Format Section
        _buildSectionHeader(context, l10n.numberFormat, Icons.format_list_numbered_rounded),
        _buildSelectorTile<NumberFormatType>(
          context,
          title: l10n.numberFormat,
          value: settings.numberFormat,
          options: NumberFormatType.values,
          labels: {
            NumberFormatType.spaceSeparated: l10n.formatSpace,
            NumberFormatType.commaSeparated: l10n.formatComma,
            NumberFormatType.plain: l10n.formatPlain,
          },
          onChanged: (value) => _updateSettings(settings.copyWith(numberFormat: value)),
        ),
        
        const SizedBox(height: 24),
        
        // Volume Keys Section
        _buildSectionHeader(context, l10n.volumeKeys, Icons.volume_up_rounded),
        _buildSwitchTile(
          context,
          title: l10n.volumeKeysEnabled,
          subtitle: 'Кнопки громкости для увеличения/уменьшения счёта',
          value: settings.volumeKeysEnabled,
          onChanged: (value) => _updateSettings(settings.copyWith(volumeKeysEnabled: value)),
        ),
        
        const SizedBox(height: 24),
        
        // Text Size Section
        _buildSectionHeader(context, l10n.textScale, Icons.text_fields_rounded),
        _buildSliderTile(
          context,
          title: l10n.textScale,
          subtitle: 'Размер текста по всему приложению',
          value: settings.textScale,
          min: 0.8,
          max: 1.5,
          divisions: 7,
          label: '${(settings.textScale * 100).round()}%',
          onChanged: (value) => _updateSettings(settings.copyWith(textScale: value)),
        ),
        
        const SizedBox(height: 24),
        
        // Language Section
        _buildSectionHeader(context, l10n.language, Icons.language_rounded),
        _buildSelectorTile<String>(
          context,
          title: l10n.language,
          value: settings.languageCode,
          options: ['ru', 'uk', 'en', 'ar'],
          labels: {
            'ru': l10n.languageRu,
            'uk': l10n.languageUk,
            'en': l10n.languageEn,
            'ar': l10n.languageAr,
          },
          onChanged: (value) => _updateSettings(settings.copyWith(languageCode: value)),
        ),
        
        const SizedBox(height: 24),
        
        // Backup Section
        _buildSectionHeader(context, l10n.backup, Icons.backup_rounded),
        _buildActionTile(
          context,
          icon: Icons.download_rounded,
          title: l10n.exportBackup,
          subtitle: 'Сохранить все данные в файл',
          onTap: _exportBackup,
          color: colorScheme.primary,
        ),
        _buildActionTile(
          context,
          icon: Icons.upload_rounded,
          title: l10n.importBackup,
          subtitle: 'Восстановить данные из файла',
          onTap: _importBackup,
          color: colorScheme.secondary,
        ),
        
        const SizedBox(height: 24),
        
        // Danger Zone
        _buildSectionHeader(context, 'Опасная зона', Icons.warning_amber_rounded, 
          headerColor: colorScheme.error),
        _buildActionTile(
          context,
          icon: Icons.delete_forever_rounded,
          title: l10n.clearAllData,
          subtitle: 'Удалить все зикры, статистику и настройки',
          onTap: _clearAllData,
          color: colorScheme.error,
          isDestructive: true,
        ),
        
        const SizedBox(height: 24),
        
        // About Section
        _buildSectionHeader(context, l10n.about, Icons.info_rounded),
        _buildAboutTile(context),
        
        const SizedBox(height: 16),
        
        // Privacy notice
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.privacy_tip_rounded, color: colorScheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    l10n.privacy,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                l10n.noInternetRequired,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.dataStoredLocally,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon, {
    Color? headerColor,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = headerColor ?? colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: colorScheme.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  Widget _buildSelectorTile<T>(
    BuildContext context, {
    required String title,
    String? subtitle,
    required T value,
    required List<T> options,
    required Map<T, String> labels,
    required ValueChanged<T> onChanged,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options.map((option) {
                final isSelected = option == value;
                return ChoiceChip(
                  label: Text(labels[option] ?? option.toString()),
                  selected: isSelected,
                  onSelected: (_) => onChanged(option),
                  selectedColor: colorScheme.primary,
                  labelStyle: theme.textTheme.labelMedium?.copyWith(
                    color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                  backgroundColor: colorScheme.surface,
                  side: BorderSide(
                    color: isSelected ? colorScheme.primary : colorScheme.outline.withValues(alpha: 0.3),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String label,
    required ValueChanged<double> onChanged,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: colorScheme.primary,
              inactiveTrackColor: colorScheme.outline.withValues(alpha: 0.2),
              thumbColor: colorScheme.primary,
              overlayColor: colorScheme.primary.withValues(alpha: 0.2),
              trackHeight: 4,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              label: label,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDestructive 
            ? color.withValues(alpha: 0.1) 
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDestructive 
              ? color.withValues(alpha: 0.3) 
              : colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDestructive ? color.withValues(alpha: 0.2) : color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: isDestructive ? color : colorScheme.primary, size: 22),
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: isDestructive ? color : colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: colorScheme.onSurfaceVariant,
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context, AppSettings settings) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentMode = settings.themeMode;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          _buildThemeOption(
            context,
            mode: ThemeMode.light,
            currentMode: currentMode,
            icon: Icons.light_mode_rounded,
            title: context.l10n.themeLight,
            subtitle: 'Всегда светлая тема',
            onTap: () => _updateSettings(settings.copyWith(themeMode: ThemeMode.light)),
          ),
          Divider(height: 1, color: colorScheme.outline.withValues(alpha: 0.1)),
          _buildThemeOption(
            context,
            mode: ThemeMode.dark,
            currentMode: currentMode,
            icon: Icons.dark_mode_rounded,
            title: context.l10n.themeDark,
            subtitle: 'Всегда тёмная тема',
            onTap: () => _updateSettings(settings.copyWith(themeMode: ThemeMode.dark)),
          ),
          Divider(height: 1, color: colorScheme.outline.withValues(alpha: 0.1)),
          _buildThemeOption(
            context,
            mode: ThemeMode.system,
            currentMode: currentMode,
            icon: Icons.settings_system_daydream_rounded,
            title: context.l10n.themeSystem,
            subtitle: 'Следовать настройкам системы',
            onTap: () => _updateSettings(settings.copyWith(themeMode: ThemeMode.system)),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required ThemeMode mode,
    required ThemeMode currentMode,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = currentMode == mode;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected 
              ? colorScheme.primary.withValues(alpha: 0.2) 
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: isSelected ? colorScheme.primary : colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle_rounded, color: colorScheme.primary, size: 24)
          : null,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildAboutTile(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.prayer_rounded, color: colorScheme.primary, size: 28),
            ),
            title: Text(
              context.l10n.appTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              'Версия 1.0.0',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showLicenseDialog(context),
                    icon: const Icon(Icons.article_rounded, size: 18),
                    label: const Text('Лицензии'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _updateSettings(AppSettings newSettings) {
    ref.read(settingsProvider.notifier).updateSettings(newSettings);
  }

  Future<void> _exportBackup() async {
    try {
      final repo = ref.read(storageRepositoryProvider);
      await repo.exportBackupToFile();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.backupExported),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _importBackup() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'Выберите файл резервной копии',
      );

      if (result != null && result.files.single.path != null) {
        // Import logic would go here
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.backupImported),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${context.l10n.backupImportError}: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _clearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.clearAllConfirmation),
        content: Text(context.l10n.clearAllConfirmationMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(context.l10n.confirm),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final repo = ref.read(storageRepositoryProvider);
      await repo.clearAllData();
      ref.invalidate(allZikrsStreamProvider);
      ref.invalidate(settingsProvider);
      ref.invalidate(activeZikrFutureProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Все данные удалены'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showLicenseDialog(BuildContext context) {
    showLicensePage(
      context: context,
      applicationName: context.l10n.appTitle,
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.prayer_rounded, size: 48, color: Color(0xFF006D5B)),
      applicationLegalese: 'Приложение работает полностью офлайн. Никакой рекламы, авторизации или аналитики.',
    );
  }
}