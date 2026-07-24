// Path Screen - Calendar, Stats, Streaks

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/models/zikr_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/storage/storage_repository_impl.dart';
import '../../widgets/common/common_widgets.dart';
import '../../widgets/path/path_widgets.dart';
import '../../../providers/zikr_providers.dart';

class PathScreen extends ConsumerStatefulWidget {
  const PathScreen({super.key});

  @override
  ConsumerState<PathScreen> createState() => _PathScreenState();
}

class _PathScreenState extends ConsumerState<PathScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final statsAsync = ref.watch(dailyStatsFutureProvider);
    final streakAsync = ref.watch(currentStreakProvider);
    totalStatsAsync = ref.watch(totalStatisticsProvider);
    final zikrsAsync = ref.watch(allZikrsFutureProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.path),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          // Calendar Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: _buildCalendarSection(statsAsync, l10n),
            ),
          ),

          // Streak Cards
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildStreakCards(streakAsync, l10n),
            ),
          ),

          // Total Stats
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: _buildTotalStats(totalStatsAsync, l10n),
            ),
          ),

          // Zikr-specific stats
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: _buildZikrStats(zikrsAsync, statsAsync, l10n),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarSection(
    AsyncValue<List<DailyStat>> statsAsync,
    AppLocalizations l10n,
  ) {
    return statsAsync.when(
      loading: () => const LoadingState(message: 'Загрузка календаря...'),
      error: (error, _) => ErrorState(
        message: error.toString(),
        onRetry: () => ref.invalidate(dailyStatsFutureProvider),
      ),
      data: (stats) {
        final statMap = {for (var s in stats) s.dateKey: s};

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.calendar,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TableCalendar<DailyStat>(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.now().add(const Duration(days: 365)),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    setState(() => _calendarFormat = format);
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    outsideDaysVisible: false,
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: Theme.of(context).textTheme.titleMedium!,
                  ),
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      final key = day.toIso8601String().split('T').first;
                      final stat = statMap[key];
                      
                      if (stat != null && stat.hasActivity) {
                        return Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              day.day.toString(),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }
                      return null;
                    },
                    markerBuilder: (context, day, events) {
                      final key = day.toIso8601String().split('T').first;
                      final stat = statMap[key];
                      
                      if (stat != null && stat.hasActivity) {
                        return Positioned(
                          bottom: 2,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      }
                      return null;
                    },
                  ),
                ),
                
                if (_selectedDay != null) ...[
                  const SizedBox(height: 16),
                  _buildDayDetail(statMap[_selectedDay!.toIso8601String().split('T').first], l10n),
                ],
              ],
            ),
          ).animate().fadeIn().slideY(begin: 0.1),
        );
      },
    );
  }

  Widget _buildDayDetail(DailyStat? stat, AppLocalizations l10n) {
    if (stat == null || !stat.hasActivity) {
      return Text(
        l10n.noData,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ).animate().fadeIn();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateFormat('d MMMM yyyy', 'ru').format(_selectedDay!),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _StatPill(
              icon: Icons.countertops_rounded,
              label: l10n.currentCount,
              value: stat.totalCount.toString(),
            ),
            const SizedBox(width: 12),
            _StatPill(
              icon: Icons.flag_rounded,
              label: l10n.completedTargets,
              value: stat.totalCompletedTargets.toString(),
            ),
            const SizedBox(width: 12),
            _StatPill(
              icon: Icons.timer_rounded,
              label: l10n.practiceTime,
              value: _formatDuration(stat.totalTimeSeconds),
            ),
          ],
        ),
        if (stat.zikrCounts.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: stat.zikrCounts.entries.map((entry) {
              final count = entry.value;
              if (count == 0) return const SizedBox.shrink();
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              );
            }).toList(),
          ),
        ],
      ],
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildStreakCards(
    AsyncValue<int> streakAsync,
    AppLocalizations l10n,
  ) {
    return streakAsync.when(
      loading: () => const LoadingState(message: 'Загрузка...'),
      error: (_, _) => const SizedBox.shrink(),
      data: (streak) {
        if (streak == 0) return const SizedBox.shrink();
        
        return Row(
          children: [
            Expanded(
              child: _StreakCard(
                icon: Icons.local_fire_department_rounded,
                value: streak,
                label: l10n.dayStreak.replaceAll('{count}', streak.toString()),
                color: Colors.orange,
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTotalStats(
    AsyncValue<Map<String, int>> statsAsync,
    AppLocalizations l10n,
  ) {
    return statsAsync.when(
      loading: () => const LoadingState(message: 'Загрузка статистики...'),
      error: (_, _) => const SizedBox.shrink(),
      data: (stats) => Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.countertops_rounded,
              value: _formatNumber(stats['totalCount'] ?? 0),
              label: l10n.currentCount,
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              icon: Icons.flag_rounded,
              value: _formatNumber(stats['totalTargets'] ?? 0),
              label: l10n.completedTargets,
            ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.2),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              icon: Icons.timer_rounded,
              value: _formatDuration(stats['totalTimeSeconds'] ?? 0),
              label: l10n.practiceTime,
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              icon: Icons.calendar_today_rounded,
              value: _formatNumber(stats['activeDays'] ?? 0),
              label: l10n.today,
            ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildZikrStats(
    AsyncValue<List<Zikr>> zikrsAsync,
    AsyncValue<List<DailyStat>> statsAsync,
    AppLocalizations l10n,
  ) {
    return zikrsAsync.when(
      loading: () => const LoadingState(message: 'Загрузка зикров...'),
      error: (_, _) => const SizedBox.shrink(),
      data: (zikrs) {
        return statsAsync.when(
          loading: () => const LoadingState(message: 'Загрузка...'),
          error: (_, _) => const SizedBox.shrink(),
          data: (stats) {
            final customZikrs = zikrs.where((z) => z.category == ZikrCategory.custom).toList();
            final sunnahZikrs = zikrs.where((z) => z.category == ZikrCategory.sunnahAzkar).toList();
            
            final allZikrsToShow = [...customZikrs, ...sunnahZikrs];
            
            if (allZikrsToShow.isEmpty) return const SizedBox.shrink();

            // Aggregate stats per zikr
            final zikrStats = <String, Map<String, int>>{};
            for (final stat in stats) {
              for (final entry in stat.zikrCounts.entries) {
                zikrStats.putIfAbsent(entry.key, () => {
                  'count': 0,
                  'time': 0,
                  'targets': 0,
                });
                zikrStats[entry.key]!['count'] = 
                    (zikrStats[entry.key]!['count'] ?? 0) + entry.value;
              }
              for (final entry in stat.zikrTimeSeconds.entries) {
                zikrStats.putIfAbsent(entry.key, () => {
                  'count': 0,
                  'time': 0,
                  'targets': 0,
                });
                zikrStats[entry.key]!['time'] = 
                    (zikrStats[entry.key]!['time'] ?? 0) + entry.value;
              }
              for (final entry in stat.completedTargets.entries) {
                zikrStats.putIfAbsent(entry.key, () => {
                  'count': 0,
                  'time': 0,
                  'targets': 0,
                });
                zikrStats[entry.key]!['targets'] = 
                    (zikrStats[entry.key]!['targets'] ?? 0) + entry.value;
              }
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'По зикрам',
                  style: Theme.of(context).textTheme.titleLarge,
                ).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: allZikrsToShow.length,
                  itemBuilder: (context, index) {
                    final zikr = allZikrsToShow[index];
                    final s = zikrStats[zikr.id] ?? {'count': 0, 'time': 0, 'targets': 0};
                    
                    if (s['count'] == 0 && zikr.currentCount == 0) {
                      return const SizedBox.shrink();
                    }
                    
                    return _ZikrStatTile(
                      zikr: zikr,
                      totalCount: s['count']! + zikr.currentCount,
                      totalTime: s['time']! + zikr.practiceTimeSeconds,
                      completedTargets: s['targets']! + zikr.completedTargets,
                    ).animate().fadeIn(delay: (450 + index * 50).ms).slideX(begin: 0.1);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    }
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '${seconds}с';
    if (seconds < 3600) return '${(seconds / 60).round()}м';
    final hours = (seconds / 3600).floor();
    final minutes = ((seconds % 3600) / 60).round();
    if (minutes == 0) return '${hours}ч';
    return '${hours}ч ${minutes}м';
  }
}

// ============================================
// HELPER WIDGETS
// ============================================

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: theme.colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;
  final Color color;

  const _StreakCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ZikrStatTile extends StatelessWidget {
  final Zikr zikr;
  final int totalCount;
  final int totalTime;
  final int completedTargets;

  const _ZikrStatTile({
    required this.zikr,
    required this.totalCount,
    required this.totalTime,
    required this.completedTargets,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final zikrColor = Color(zikr.colorValue);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: zikrColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.prayer_rounded, color: zikrColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  zikr.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Текущий: ${zikr.formattedCurrentCount} / ${zikr.formattedTargetCount}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatNumber(totalCount),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${completedTargets} целей • ${_formatDuration(totalTime)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    }
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '${seconds}с';
    if (seconds < 3600) return '${(seconds / 60).round()}м';
    final hours = (seconds / 3600).floor();
    final minutes = ((seconds % 3600) / 60).round();
    if (minutes == 0) return '${hours}ч';
    return '${hours}ч ${minutes}м';
  }
}