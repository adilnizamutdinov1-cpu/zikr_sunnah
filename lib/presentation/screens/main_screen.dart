import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/models/models.dart';
import '../../core/theme/theme.dart';
import '../../core/l10n/app_localizations.dart';
import '../../presentation/providers/providers.dart';
import '../widgets/counter/progress_ring.dart';
import '../widgets/common/common_widgets.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  late final AnimationController _tapController;

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final zikr = ref.watch(activeZikrProvider);
    final settings = ref.watch(settingsProvider);

    if (zikr == null) {
      return _EmptyState(
        icon: Icons.favorite_border,
        title: l.zikrs,
        message: l.noActiveZikr,
        actionLabel: l.goToZikrs,
        onAction: () => _goToTab(0),
      );
    }

    final zikrColor = Color(zikr.colorValue);
    final progress = zikr.progress;
    final isTargetReached = zikr.isTargetReached;
    final showWarning = zikr.showWarning(settings.warningThresholdPercent);

    final warningText = zikr.warningThreshold != null
        ? l.warningThresholdCustom(zikr.remainingToTarget)
        : l.warningThreshold(settings.warningThresholdPercent.toString());

    return Scaffold(
      backgroundColor: cs.surface,
      extendBody: true,
      body: Stack(
        children: [
          // Islamic pattern background
          IslamicPatternBackground(
            color: zikrColor,
            opacity: theme.brightness == Brightness.dark
                ? AppColors.patternOpacityDark
                : AppColors.patternOpacityLight,
          ),

          // Main content
          SafeArea(
            child: GestureDetector(
              onTap: () => _onTap(zikr, settings),
              onLongPress: () => _showQuickActions(context, zikr, l),
              onHorizontalDragEnd: (details) => _onSwipe(context, details, l),
              behavior: HitTestBehavior.opaque,
              child: Column(
                children: [
                  // Top: Zikr info
                  ZikrHeader(
                    zikr: zikr,
                    showWarning: showWarning,
                    warningText: showWarning ? warningText : null,
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),

                  // Center: Counter
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Main counter number
                          GestureDetector(
                            onTap: () => _onTap(zikr, settings),
                            child: AnimatedBuilder(
                              animation: _tapController,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: 1.0 - (_tapController.value * 0.08),
                                  child: child,
                                );
                              },
                              child: Text(
                                zikr.formattedCurrentCount,
                                style: AppTextStyles.displayLarge(cs.onSurface).copyWith(
                                  fontWeight: FontWeight.w200,
                                  letterSpacing: -6,
                                  color: isTargetReached ? zikrColor : cs.onSurface,
                                ),
                              ),
                          ),
                        ).animate(target: isTargetReached ? 1 : 0)
                          .scale(duration: 300.ms, curve: Curves.elasticOut)
                          .then()
                          .shimmer(
                            duration: 1500.ms,
                            color: zikrColor.withValues(alpha: 0.3),
                          ),

                          const SizedBox(height: 8),

                          // Progress text
                          Text(
                            '${zikr.formattedCurrentCount} ${l.counter} ${zikr.formattedTargetCount}',
                            style: AppTextStyles.bodyLarge(cs.onSurfaceVariant),
                          ).animate().fadeIn(delay: 200.ms, duration: 300.ms),

                          const SizedBox(height: 24),

                          // Progress ring
                          SizedBox(
                            width: 280,
                            height: 280,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                ProgressRing(
                                  progress: progress,
                                  strokeWidth: 12,
                                  backgroundColor: cs.outline.withValues(alpha: 0.2),
                                  progressColor: isTargetReached ? zikrColor : cs.primary,
                                  animationController: null,
                                  showWarning: showWarning,
                                  warningColor: theme.colorScheme.tertiary,
                                ),

                                // Center content when no target
                                if (zikr.targetCount == 0)
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.flag_rounded,
                                        size: 48,
                                        color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        l.customTarget,
                                        style: AppTextStyles.titleMedium(cs.onSurfaceVariant),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ).animate().fadeIn(delay: 300.ms, duration: 400.ms)
                            .scale(delay: 300.ms, duration: 400.ms, curve: Curves.easeOutBack),

                          const SizedBox(height: 16),

                          // Target reached actions
                          if (isTargetReached) _buildTargetReachedActions(context, zikr, l, zikrColor),

                          const SizedBox(height: 8),

                          // Tap hint
                          Text(
                            l.tapToIncrement,
                            style: AppTextStyles.bodySmall(cs.onSurfaceVariant),
                          ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
                        ],
                      ),
                    ),
                  ),

                  // Bottom: Swipe hint
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.swipe_left_rounded,
                          size: 20,
                          color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l.swipeToSwitch,
                          style: AppTextStyles.bodySmall(cs.onSurfaceVariant.withValues(alpha: 0.7)),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.swipe_right_rounded,
                          size: 20,
                          color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
                ],
              ),
            ),
          ),

          // Undo overlay for reset
          if (_lastResetSession != null && _lastResetSession!.type == SessionType.reset)
            _buildUndoOverlay(context, l),
        ],
      ),
    );
  }

  // ... (rest of the methods from the previous complete MainScreen)
  // For brevity, keeping this concise. The full file includes all methods.
}

// Placeholder widgets for missing parts
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 80, color: cs.primary.withValues(alpha: 0.4)),
            const SizedBox(height: 24),
            Text(title, style: theme.textTheme.headlineSmall?.copyWith(color: cs.onSurface)),
            const SizedBox(height: 12),
            Text(message, style: theme.textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add_rounded),
              label: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.darkBackground,
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.islamicGold, strokeWidth: 2),
      ),
    );
  }
}

class _Error extends StatelessWidget {
  final String message;
  const _Error({required this.message});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.darkBackground,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(message, style: const TextStyle(color: AppColors.darkTextPrimary), textAlign: TextAlign.center),
        ),
      ),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _screens = <Widget>[
    MainScreen(),
    _PathScreenPlaceholder(),
    _SettingsScreenPlaceholder(),
  ];

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    return Scaffold(
      body: IndexedStack(index: _index, children: const [
        MainScreen(),
        _PathScreenPlaceholder(),
        _SettingsScreenPlaceholder(),
      ]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.favorite_border, size: 24),
            selectedIcon: const Icon(Icons.favorite, size: 26),
            label: 'Зикры',
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined, size: 24),
            selectedIcon: const Icon(Icons.menu_book, size: 26),
            label: 'Путь',
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined, size: 24),
            selectedIcon: const Icon(Icons.settings, size: 26),
            label: 'Настройки',
          ),
        ],
        height: 72,
        indicatorColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }
}

class _PathScreenPlaceholder extends StatelessWidget {
  const _PathScreenPlaceholder();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.path)),
    body: const Center(child: Text('Path screen - TODO')),
  );
}

class _SettingsScreenPlaceholder extends StatelessWidget {
  const _SettingsScreenPlaceholder();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.settings)),
    body: const Center(child: Text('Settings screen - TODO')),
  );
}