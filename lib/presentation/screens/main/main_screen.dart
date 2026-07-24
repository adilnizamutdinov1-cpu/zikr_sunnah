// Main Screen - Counter with Progress Ring
// Central tap zone, swipe to switch zikrs, haptics, animations

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vibration/vibration.dart';

import '../../core/models/zikr_models.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/storage/storage_repository_impl.dart';
import '../widgets/common/islamic_pattern_bg.dart';
import '../widgets/counter/progress_ring.dart';
import '../widgets/counter/zikr_header.dart';
import '../../providers/zikr_providers.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> 
    with TickerProviderStateMixin {
  late AnimationController _tapController;
  late AnimationController _progressController;
  late AnimationController _warningController;
  
  ZikrSession? _lastSession;
  DateTime? _lastTapTime;
  int _tapCountInSession = 0;

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _warningController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tapController.dispose();
    _progressController.dispose();
    _warningController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final activeZikrAsync = ref.watch(activeZikrProvider);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      extendBody: true,
      body: activeZikrAsync.when(
        loading: () => _buildLoadingState(context),
        error: (e, _) => _buildErrorState(context, e),
        data: (zikr) => zikr != null 
          ? _buildCounterScreen(context, zikr, settings, l10n)
          : _buildEmptyState(context, l10n),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: CircularProgressIndicator(
        color: theme.colorScheme.primary,
        strokeWidth: 3,
      ).animate().fadeIn(duration: 300.ms).scale(),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: theme.colorScheme.error,
            ).animate().fadeIn().scale(),
            const SizedBox(height: 16),
            Text(
              l10n.noData,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 8),
            Text(
              'Error: $error',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.prayer_rounded,
              size: 80,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ).animate().fadeIn().scale(),
            const SizedBox(height: 24),
            Text(
              l10n.noData,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 12),
            Text(
              'Add your first zikr to begin',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterScreen(
    BuildContext context,
    Zikr zikr,
    AppSettings settings,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final zikrColor = Color(zikr.colorValue);
    
    // Calculate progress
    final progress = zikr.progress;
    final isTargetReached = zikr.isTargetReached;
    final showWarning = zikr.showWarning;
    
    return Stack(
      children: [
        // Background with Islamic pattern
        IslamicPatternBackground(
          color: zikrColor,
          opacity: theme.brightness == Brightness.dark 
            ? AppColors.patternOpacityDark 
            : AppColors.patternOpacityLight,
        ),
        
        // Main content
        SafeArea(
          child: GestureDetector(
            onTap: () => _onTap(context, zikr, settings),
            onLongPress: () => _showQuickActions(context, zikr, l10n),
            onHorizontalDragEnd: (details) => _onSwipe(context, details, l10n),
            behavior: HitTestBehavior.opaque,
            child: Column(
              children: [
                // Top: Zikr info
                ZikrHeader(
                  zikr: zikr,
                  showWarning: showWarning,
                  warningText: showWarning 
                    ? l10n.warningThreshold.replaceAll('{count}', zikr.remainingToTarget.toString())
                    : null,
                ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),
                
                // Center: Counter
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Main counter number
                        GestureDetector(
                          onTap: () => _onTap(context, zikr, settings),
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
                              style: AppTextStyles.displayLarge(colorScheme.onSurface).copyWith(
                                fontWeight: FontWeight.w200,
                                letterSpacing: -6,
                                color: isTargetReached ? zikrColor : colorScheme.onSurface,
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
                          '${zikr.formattedCurrentCount} ${l10n.counter} ${zikr.formattedTargetCount}',
                          style: AppTextStyles.bodyLarge(colorScheme.onSurfaceVariant),
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
                                backgroundColor: colorScheme.outline.withValues(alpha: 0.2),
                                progressColor: isTargetReached ? zikrColor : colorScheme.primary,
                                animationController: _progressController,
                                showWarning: showWarning,
                                warningColor: colorScheme.tertiary,
                              ),
                              
                              // Center content when not showing progress
                              if (zikr.targetCount == 0)
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.flag_rounded,
                                      size: 48,
                                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      l10n.customTarget,
                                      style: AppTextStyles.titleMedium(colorScheme.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 300.ms, duration: 400.ms)
                          .scale(delay: 300.ms, duration: 400.ms, curve: Curves.easeOutBack),
                        
                        const SizedBox(height: 16),
                        
                        // Target reached actions
                        if (isTargetReached) _buildTargetReachedActions(context, zikr, l10n, zikrColor),
                        
                        const SizedBox(height: 8),
                        
                        // Tap hint
                        Text(
                          l10n.tapToIncrement,
                          style: AppTextStyles.bodySmall(colorScheme.onSurfaceVariant),
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
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.swipeToSwitch,
                        style: AppTextStyles.bodySmall(colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.swipe_right_rounded,
                        size: 20,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                    ],
                  ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
                ),
              ],
            ),
          ),
        ),
        
        // Undo snackbar overlay
        if (_lastSession != null && _lastSession!.type == SessionType.reset)
          _buildUndoOverlay(context, l10n),
      ],
    );
  }

  Widget _buildTargetReachedActions(
    BuildContext context,
    Zikr zikr,
    AppLocalizations l10n,
    Color zikrColor,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: zikrColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: zikrColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_rounded, color: zikrColor, size: 24),
              const SizedBox(width: 12),
              Text(
                l10n.targetReached,
                style: AppTextStyles.titleMedium(zikrColor).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms).scale(),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: () => _startNewRound(context, zikr),
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: Text(l10n.newRound),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: () => _continueCounting(context, zikr),
              icon: const Icon(Icons.add_rounded, size: 20),
              label: Text(l10n.continueCounting),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
          ],
        ),
      ],
    );
  }

  Widget _buildUndoOverlay(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Positioned(
      bottom: 100,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: theme.colorScheme.inverseSurface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.undo_rounded,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                l10n.undoAvailable,
                style: AppTextStyles.bodyLarge(theme.colorScheme.onInverseSurface),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: () => _undoReset(context),
                child: Text(
                  l10n.undo,
                  style: AppTextStyles.labelLarge(theme.colorScheme.primary),
                ),
              ),
            ],
          ),
        ).animate().fadeIn().slideY(begin: 1),
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: theme.brightness == Brightness.dark ? 0.3 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                icon: Icons.prayer_rounded,
                activeIcon: Icons.prayer_rounded,
                label: context.l10n.counter,
                index: 0,
                onTap: () {}, // Already on main screen
              ),
              _buildNavItem(
                context,
                icon: Icons.menu_book_rounded,
                activeIcon: Icons.menu_book_rounded,
                label: context.l10n.zikrs,
                index: 1,
                onTap: () => _navigateToZikrs(context),
              ),
              _buildNavItem(
                context,
                icon: Icons.route_rounded,
                activeIcon: Icons.route_rounded,
                label: context.l10n.path,
                index: 2,
                onTap: () => _navigateToPath(context),
              ),
              _buildNavItem(
                context,
                icon: Icons.settings_rounded,
                activeIcon: Icons.settings_rounded,
                label: context.l10n.settings,
                index: 3,
                onTap: () => _navigateToSettings(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // For now, all inactive since we're on main screen
    final isActive = false;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 24,
              color: isActive ? colorScheme.primary : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.labelSmall(
                isActive ? colorScheme.primary : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // ACTIONS
  // ============================================
  
  void _onTap(BuildContext context, Zikr zikr, AppSettings settings) {
    final now = DateTime.now();
    
    // Track session time
    if (_lastTapTime != null) {
      final sessionSeconds = now.difference(_lastTapTime!).inSeconds;
      if (sessionSeconds < 3600) { // Only count if less than 1 hour gap
        _tapCountInSession += sessionSeconds;
      }
    }
    _lastTapTime = now;
    
    // Haptic feedback
    if (settings.hapticsEnabled) {
      _triggerHaptic(settings.hapticIntensity, zikr);
    }
    
    // Animation
    _tapController.forward().then((_) => _tapController.reverse());
    _progressController.animateTo(zikr.progress);
    
    // Warning vibration
    if (zikr.showWarning && !zikr.isTargetReached) {
      _triggerWarningHaptic(settings.hapticIntensity);
    }
    
    // Target reached haptic
    if (zikr.isTargetReached && _tapCountInSession == 1) {
      _triggerTargetHaptic(settings.hapticIntensity);
    }
    
    // Update counter
    ref.read(counterProvider(zikr.id).notifier).increment();
    
    // Save session
    final session = ZikrSession(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      zikrId: zikr.id,
      previousCount: zikr.currentCount - 1,
      newCount: zikr.currentCount,
      timestamp: now,
      type: SessionType.increment,
    );
    ref.read(storageRepositoryProvider).saveSession(session);
  }

  void _triggerHaptic(HapticIntensity intensity, Zikr zikr) {
    switch (intensity) {
      case HapticIntensity.light:
        Vibration.vibrate(duration: 10, amplitude: 30);
        break;
      case HapticIntensity.medium:
        Vibration.vibrate(duration: 15, amplitude: 60);
        break;
      case HapticIntensity.heavy:
        Vibration.vibrate(duration: 20, amplitude: 100);
        break;
    }
  }

  void _triggerWarningHaptic(HapticIntensity intensity) {
    // Double tap pattern for warning
    Vibration.vibrate(pattern: [0, 30, 50, 30], amplitudes: [0, 80, 0, 80]);
  }

  void _triggerTargetHaptic(HapticIntensity intensity) {
    // Celebration pattern
    Vibration.vibrate(pattern: [0, 50, 50, 50, 50, 100], amplitudes: [0, 100, 0, 100, 0, 150]);
  }

  void _onSwipe(BuildContext context, DragEndDetails details, AppLocalizations l10n) {
    if (details.primaryVelocity == null) return;
    
    final velocity = details.primaryVelocity!;
    if (velocity.abs() > 300) {
      ref.read(zikrListProvider.notifier).switchZikr(velocity < 0);
      
      // Light haptic for swipe
      if (ref.read(settingsProvider).hapticsEnabled) {
        Vibration.vibrate(duration: 10, amplitude: 40);
      }
    }
  }

  void _showQuickActions(BuildContext context, Zikr zikr, AppLocalizations l10n) {
    if (ref.read(settingsProvider).hapticsEnabled) {
      Vibration.vibrate(duration: 20, amplitude: 80);
    }
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _QuickActionsSheet(zikr: zikr, l10n: l10n),
    );
  }

  void _startNewRound(BuildContext context, Zikr zikr) {
    ref.read(counterProvider(zikr.id).notifier).resetCurrent();
    
    // Save session
    final session = ZikrSession(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      zikrId: zikr.id,
      previousCount: zikr.currentCount,
      newCount: 0,
      timestamp: DateTime.now(),
      type: SessionType.newRound,
    );
    ref.read(storageRepositoryProvider).saveSession(session);
  }

  void _continueCounting(BuildContext context, Zikr zikr) {
    // Just continue - no action needed as counter already incremented
    ref.read(counterProvider(zikr.id).notifier).continueCounting();
  }

  void _undoReset(BuildContext context) {
    if (_lastSession != null) {
      ref.read(counterProvider(_lastSession!.zikrId).notifier)
        .setCount(_lastSession!.previousCount);
      setState(() => _lastSession = null);
    }
  }

  void _navigateToZikrs(BuildContext context) {
    Navigator.of(context).pushNamed('/zikrs');
  }

  void _navigateToPath(BuildContext context) {
    Navigator.of(context).pushNamed('/path');
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.of(context).pushNamed('/settings');
  }
}

// ============================================
// QUICK ACTIONS SHEET
// ============================================
class _QuickActionsSheet extends ConsumerWidget {
  final Zikr zikr;
  final AppLocalizations l10n;

  const _QuickActionsSheet({required this.zikr, required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final zikrColor = Color(zikr.colorValue);
    
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ).animate().fadeIn().scale(),
              
              const SizedBox(height: 20),
              
              // Zikr name
              Text(
                zikr.name,
                style: AppTextStyles.headlineSmall(colorScheme.onSurface),
              ).animate().fadeIn(delay: 100.ms),
              
              const SizedBox(height: 24),
              
              // Action buttons
              _ActionButton(
                icon: Icons.add_rounded,
                label: l10n.increment1,
                onTap: () {
                  ref.read(counterProvider(zikr.id).notifier).increment();
                  Navigator.pop(context);
                },
                color: zikrColor,
              ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.2),
              
              _ActionButton(
                icon: Icons.add_rounded,
                label: l10n.increment10,
                onTap: () {
                  ref.read(counterProvider(zikr.id).notifier).incrementBy(10);
                  Navigator.pop(context);
                },
                color: zikrColor,
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
              
              _ActionButton(
                icon: Icons.add_rounded,
                label: l10n.increment100,
                onTap: () {
                  ref.read(counterProvider(zikr.id).notifier).incrementBy(100);
                  Navigator.pop(context);
                },
                color: zikrColor,
              ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.2),
              
              _ActionButton(
                icon: Icons.edit_rounded,
                label: l10n.setExact,
                onTap: () {
                  Navigator.pop(context);
                  _showExactNumberDialog(context, ref, zikr, l10n);
                },
                color: colorScheme.primary,
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
              
              const SizedBox(height: 12),
              
              Divider(color: colorScheme.outline.withValues(alpha: 0.2))
                .animate().fadeIn(delay: 350.ms),
              
              const SizedBox(height: 12),
              
              _ActionButton(
                icon: Icons.refresh_rounded,
                label: l10n.newRound,
                onTap: () {
                  ref.read(counterProvider(zikr.id).notifier).resetCurrent();
                  Navigator.pop(context);
                },
                color: colorScheme.tertiary,
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
              
              _ActionButton(
                icon: Icons.delete_sweep_rounded,
                label: l10n.reset,
                onTap: () {
                  Navigator.pop(context);
                  _showResetConfirmation(context, ref, zikr, l10n);
                },
                color: colorScheme.error,
                isDestructive: true,
              ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.2),
            ],
          ),
        ),
      ),
    );
  }

  void _showExactNumberDialog(BuildContext context, WidgetRef ref, Zikr zikr, AppLocalizations l10n) {
    final controller = TextEditingController(text: zikr.currentCount.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.enterExactNumber),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.enterExactNumber,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final value = int.tryParse(controller.text) ?? zikr.currentCount;
              ref.read(counterProvider(zikr.id).notifier).setCount(value.clamp(0, 999999));
              Navigator.pop(context);
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmation(BuildContext context, WidgetRef ref, Zikr zikr, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetConfirmation),
        content: Text(l10n.resetConfirmationMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              // Save session for undo
              final session = ZikrSession(
                id: DateTime.now().microsecondsSinceEpoch.toString(),
                zikrId: zikr.id,
                previousCount: zikr.currentCount,
                newCount: 0,
                timestamp: DateTime.now(),
                type: SessionType.reset,
              );
              ref.read(storageRepositoryProvider).saveSession(session);
              
              ref.read(counterProvider(zikr.id).notifier).resetCurrent();
              Navigator.pop(context);
              
              // Show undo snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.undoAvailable),
                  action: SnackBarAction(
                    label: l10n.undo,
                    onPressed: () {
                      ref.read(counterProvider(zikr.id).notifier).setCount(session.previousCount);
                    },
                  ),
                  duration: const Duration(seconds: 10),
                ),
              );
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final bool isDestructive;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDestructive 
            ? color.withValues(alpha: 0.1) 
            : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTextStyles.titleMedium(color).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}