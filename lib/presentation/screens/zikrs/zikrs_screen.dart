// Zikrs Screen - Sunnah Azkar and Custom Zikrs

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/models/zikr_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/storage/storage_repository_impl.dart';
import '../../widgets/common/common_widgets.dart';
import '../../widgets/zikrs/zikr_card.dart';
import '../../widgets/zikrs/add_zikr_dialog.dart';
import '../../../providers/zikr_providers.dart';

class ZikrsScreen extends ConsumerStatefulWidget {
  const ZikrsScreen({super.key});

  @override
  ConsumerState<ZikrsScreen> createState() => _ZikrsScreenState();
}

class _ZikrsScreenState extends ConsumerState<ZikrsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.zikrs),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.sunnahAzkar),
            Tab(text: l10n.myZikrs),
          ],
          indicatorSize: TabBarIndicatorSize.label,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSunnahAzkarTab(context, l10n),
          _buildMyZikrsTab(context, l10n),
        ],
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton.extended(
              onPressed: () => _showAddZikrDialog(context),
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.addZikr),
            ).animate().fadeIn(delay: 300.ms).scale()
          : null,
    );
  }

  Widget _buildSunnahAzkarTab(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer(
      builder: (context, ref, child) {
        final zikrsAsync = ref.watch(allZikrsStreamProvider);

        return zikrsAsync.when(
          loading: () => const LoadingState(message: 'Загрузка азкаров...'),
          error: (error, _) => ErrorState(
            message: error.toString(),
            onRetry: () => ref.invalidate(allZikrsStreamProvider),
          ),
          data: (allZikrs) {
            final sunnahZikrs = allZikrs
                .where((z) => z.category == ZikrCategory.sunnahAzkar)
                .toList();

            if (sunnahZikrs.isEmpty) {
              return EmptyState(
                icon: Icons.menu_book_rounded,
                title: l10n.noData,
                message: 'Азкары по Сунне будут доступны после инициализации',
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: sunnahZikrs.length,
              itemBuilder: (context, index) {
                final zikr = sunnahZikrs[index];
                return ZikrCard(
                  zikr: zikr,
                  isSunnah: true,
                  onTap: () => _selectZikr(context, ref, zikr),
                  onLongPress: () => _showSunnahZikrOptions(context, ref, zikr),
                ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildMyZikrsTab(BuildContext context, AppLocalizations l10n) {
    return Consumer(
      builder: (context, ref, child) {
        final zikrsAsync = ref.watch(allZikrsStreamProvider);

        return zikrsAsync.when(
          loading: () => const LoadingState(message: 'Загрузка...'),
          error: (error, _) => ErrorState(
            message: error.toString(),
            onRetry: () => ref.invalidate(allZikrsStreamProvider),
          ),
          data: (allZikrs) {
            final customZikrs = allZikrs
                .where((z) => z.category == ZikrCategory.custom)
                .toList();

            return Column(
              children: [
                if (customZikrs.isEmpty)
                  Expanded(
                    child: EmptyState(
                      icon: Icons.add_circle_outline_rounded,
                      title: l10n.noData,
                      message: 'Создайте свой первый зикр для личной практики',
                      action: FilledButton.icon(
                        onPressed: () => _showAddZikrDialog(context),
                        icon: const Icon(Icons.add_rounded),
                        label: Text(l10n.addZikr),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      itemCount: customZikrs.length,
                      itemBuilder: (context, index) {
                        final zikr = customZikrs[index];
                        return ZikrCard(
                          zikr: zikr,
                          isSunnah: false,
                          onTap: () => _selectZikr(context, ref, zikr),
                          onLongPress: () => _showCustomZikrOptions(context, ref, zikr),
                        ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1);
                      },
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  void _selectZikr(BuildContext context, WidgetRef ref, Zikr zikr) async {
    final repo = ref.read(storageRepositoryProvider);
    await repo.setActiveZikrId(zikr.id);
    ref.invalidate(activeZikrFutureProvider);
    ref.invalidate(activeZikrStreamProvider);
    ref.read(activeZikrIdNotifierProvider.notifier).set(zikr.id);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${context.l10n.counter}: ${zikr.name}'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showAddZikrDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddZikrDialog(),
    );
  }

  void _showSunnahZikrOptions(BuildContext context, WidgetRef ref, Zikr zikr) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _ZikrOptionsSheet(
        zikr: zikr,
        isSunnah: true,
        onEdit: null, // Cannot edit Sunnah azkar
        onDelete: null,
        onReset: () => _resetZikr(context, ref, zikr),
        onSetTarget: () => _showSetTargetDialog(context, ref, zikr),
        onDuplicate: () => _duplicateZikr(context, ref, zikr),
      ),
    );
  }

  void _showCustomZikrOptions(BuildContext context, WidgetRef ref, Zikr zikr) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _ZikrOptionsSheet(
        zikr: zikr,
        isSunnah: false,
        onEdit: () => _editZikr(context, ref, zikr),
        onDelete: () => _deleteZikr(context, ref, zikr),
        onReset: () => _resetZikr(context, ref, zikr),
        onSetTarget: () => _showSetTargetDialog(context, ref, zikr),
        onDuplicate: () => _duplicateZikr(context, ref, zikr),
      ),
    );
  }

  Future<void> _resetZikr(BuildContext context, WidgetRef ref, Zikr zikr) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.resetConfirmation),
        content: Text(context.l10n.resetConfirmationMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.confirm),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final repo = ref.read(storageRepositoryProvider);
      final updated = zikr.resetCurrentCount();
      await repo.saveZikr(updated);
      ref.invalidate(allZikrsStreamProvider);

      // Show undo snackbar
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.undoAvailable),
            action: SnackBarAction(
              label: context.l10n.undo,
              onPressed: () async {
                await repo.saveZikr(zikr);
                ref.invalidate(allZikrsStreamProvider);
              },
            ),
            duration: const Duration(seconds: 10),
          ),
        );
      }
    }
  }

  void _showSetTargetDialog(BuildContext context, WidgetRef ref, Zikr zikr) {
    final controller = TextEditingController(text: zikr.targetCount.toString());
    final targets = [33, 100, 1000];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${context.l10n.target} ${context.l10n.forWord} "${zikr.name}"'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: context.l10n.customTarget,
                hintText: 'Например: 500',
              ),
            ),
            const SizedBox(height: 16),
            Text(context.l10n.target, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: targets.map((t) => ChoiceChip(
                label: Text(t.toString()),
                selected: zikr.targetCount == t,
                onSelected: (selected) {
                  if (selected) {
                    controller.text = t.toString();
                  }
                },
              )).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              final target = int.tryParse(controller.text) ?? zikr.targetCount;
              if (target > 0) {
                final repo = ref.read(storageRepositoryProvider);
                final updated = zikr.withNewTarget(target);
                await repo.saveZikr(updated);
                ref.invalidate(allZikrsStreamProvider);
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(context.l10n.confirm),
          ),
        ],
      ),
    );
  }

  void _editZikr(BuildContext context, WidgetRef ref, Zikr zikr) {
    showDialog(
      context: context,
      builder: (context) => AddZikrDialog(existingZikr: zikr),
    );
  }

  Future<void> _deleteZikr(BuildContext context, WidgetRef ref, Zikr zikr) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.deleteConfirmation),
        content: Text(context.l10n.deleteConfirmationMessage),
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

    if (confirmed == true && context.mounted) {
      final repo = ref.read(storageRepositoryProvider);
      await repo.deleteZikr(zikr.id);
      ref.invalidate(allZikrsStreamProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${zikr.name} ${context.l10n.counter} удалён'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _duplicateZikr(BuildContext context, WidgetRef ref, Zikr zikr) async {
    final repo = ref.read(storageRepositoryProvider);
    final duplicated = zikr.copyWith(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: '${zikr.name} (копия)',
      category: ZikrCategory.custom,
      currentCount: 0,
      totalCount: 0,
      practiceTimeSeconds: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await repo.saveZikr(duplicated);
    ref.invalidate(allZikrsStreamProvider);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${context.l10n.customZikr} создан'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

// ============================================
// ZIKR OPTIONS SHEET
// ============================================
class _ZikrOptionsSheet extends StatelessWidget {
  final Zikr zikr;
  final bool isSunnah;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback onReset;
  final VoidCallback onSetTarget;
  final VoidCallback onDuplicate;

  const _ZikrOptionsSheet({
    required this.zikr,
    required this.isSunnah,
    this.onEdit,
    this.onDelete,
    required this.onReset,
    required this.onSetTarget,
    required this.onDuplicate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Zikr info
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Color(zikr.colorValue).withValues(alpha: 0.2),
              child: Icon(
                isSunnah ? Icons.menu_book_rounded : Icons.person_rounded,
                color: Color(zikr.colorValue),
              ),
            ),
            title: Text(
              zikr.name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              isSunnah ? 'Азкар по Сунне' : 'Мой зикр',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),

          const Divider(),

          // Actions
          _buildActionTile(
            context,
            icon: Icons.flag_rounded,
            title: 'Установить цель',
            subtitle: 'Текущая: ${zikr.targetCount}',
            onTap: onSetTarget,
          ),

          _buildActionTile(
            context,
            icon: Icons.refresh_rounded,
            title: context.l10n.reset,
            subtitle: 'Обнулить текущий счёт',
            onTap: onReset,
            isDestructive: false,
          ),

          if (!isSunnah) ...[
            _buildActionTile(
              context,
              icon: Icons.edit_rounded,
              title: context.l10n.editZikr,
              onTap: onEdit,
            ),
            _buildActionTile(
              context,
              icon: Icons.content_copy_rounded,
              title: 'Дублировать',
              onTap: onDuplicate,
            ),
            _buildActionTile(
              context,
              icon: Icons.delete_rounded,
              title: context.l10n.deleteZikr,
              onTap: onDelete,
              isDestructive: true,
            ),
          ],

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? colorScheme.error : colorScheme.primary,
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: isDestructive ? colorScheme.error : colorScheme.onSurface,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}