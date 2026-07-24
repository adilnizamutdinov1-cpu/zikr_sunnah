// Riverpod Providers for Zikr State Management

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hive/hive.dart';

import '../../core/models/zikr_models.dart';
import '../../core/storage/storage_repository_impl.dart';
import '../../core/storage/hive_boxes.dart';

part 'zikr_providers.g.dart';

// ============================================
// ACTIVE ZIKR PROVIDER
// ============================================
@riverpod
Stream<Zikr?> activeZikr(ActiveZikrRef ref) async* {
  final repo = ref.watch(storageRepositoryProvider);
  await repo.initialize();
  
  // Get active zikr ID
  final activeId = await repo.getActiveZikrId();
  if (activeId == null) {
    yield null;
    return;
  }
  
  // Watch the zikr box for changes
  final box = await Hive.openBox<Zikr>(HiveBoxes.zikrs);
  
  // Initial value
  yield box.get(activeId);
  
  // Listen for changes
  final subscription = box.watch(key: activeId).listen((event) {
    // This will trigger a rebuild
  });
  
  await subscription.asFuture();
  
  // Fallback: use a periodic stream to check for updates
  yield* Stream.periodic(const Duration(milliseconds: 500), (_) => box.get(activeId));
}

// Alternative: Simple FutureProvider for active zikr
@riverpod
Future<Zikr?> activeZikrFuture(ActiveZikrFutureRef ref) async {
  final repo = ref.watch(storageRepositoryProvider);
  await repo.initialize();
  final activeId = await repo.getActiveZikrId();
  if (activeId == null) return null;
  return await repo.getZikr(activeId);
}

// Stream of all zikrs
@riverpod
Stream<List<Zikr>> allZikrsStream(AllZikrsStreamRef ref) async* {
  final repo = ref.watch(storageRepositoryProvider);
  await repo.initialize();
  
  final box = await Hive.openBox<Zikr>(HiveBoxes.zikrs);
  
  yield box.values.toList()..sort((a, b) {
    if (a.category != b.category) {
      return a.category == ZikrCategory.sunnahAzkar ? -1 : 1;
    }
    return a.createdAt.compareTo(b.createdAt);
  });
  
  await box.watch().asFuture();
}

// Settings provider
@riverpod
Future<AppSettings> settingsProvider(SettingsProviderRef ref) async {
  final repo = ref.watch(storageRepositoryProvider);
  await repo.initialize();
  return await repo.getSettings();
}

// Active zikr ID provider (for quick switching)
@riverpod
class ActiveZikrIdNotifier extends _$ActiveZikrIdNotifier {
  @override
  String? build() {
    return null;
  }
  
  Future<void> load() async {
    final repo = ref.read(storageRepositoryProvider);
    await repo.initialize();
    state = await repo.getActiveZikrId();
  }
  
  Future<void> set(String zikrId) async {
    final repo = ref.read(storageRepositoryProvider);
    await repo.setActiveZikrId(zikrId);
    state = zikrId;
    ref.invalidate(activeZikrFutureProvider);
  }
}

// Current zikr notifier (for optimistic updates)
@riverpod
class CurrentZikrNotifier extends _$CurrentZikrNotifier {
  @override
  Zikr? build() {
    return null;
  }
  
  void setZikr(Zikr zikr) {
    state = zikr;
  }
  
  void updateCount(int newCount) {
    if (state != null) {
      state = state!.copyWith(
        currentCount: newCount,
        updatedAt: DateTime.now(),
      );
    }
  }
  
  void increment(int amount) {
    if (state != null) {
      state = state!.copyWith(
        currentCount: state!.currentCount + amount,
        totalCount: state!.totalCount + amount,
        updatedAt: DateTime.now(),
      );
    }
  }
  
  void resetCurrent() {
    if (state != null) {
      state = state!.copyWith(
        currentCount: 0,
        updatedAt: DateTime.now(),
      );
    }
  }
  
  void setTarget(int target) {
    if (state != null) {
      state = state!.copyWith(
        targetCount: target,
        updatedAt: DateTime.now(),
      );
    }
  }
}

// Daily stats provider
@riverpod
class DailyStatsNotifier extends _$DailyStatsNotifier {
  @override
  DailyStat? build() {
    return null;
  }
  
  Future<void> loadToday() async {
    final repo = ref.read(storageRepositoryProvider);
    await repo.initialize();
    final today = DateTime.now().toIso8601String().split('T').first;
    state = await repo.getDailyStat(today);
  }
  
  Future<void> increment(String zikrId, int count, int seconds) async {
    final repo = ref.read(storageRepositoryProvider);
    final today = DateTime.now().toIso8601String().split('T').first;
    await repo.incrementDailyCount(today, zikrId, count, seconds);
    await loadToday();
  }
  
  Future<void> addCompletedTarget(String zikrId) async {
    final repo = ref.read(storageRepositoryProvider);
    final today = DateTime.now().toIso8601String().split('T').first;
    await repo.addCompletedTarget(today, zikrId);
    await loadToday();
  }
}

// Statistics provider for Path screen
@riverpod
Future<List<DailyStat>> statisticsProvider(StatisticsProviderRef ref) async {
  final repo = ref.watch(storageRepositoryProvider);
  await repo.initialize();
  
  final now = DateTime.now();
  final monthAgo = now.subtract(const Duration(days: 30));
  
  return await repo.getDailyStats(from: monthAgo, to: now);
}

// Streak calculator
@riverpod
int currentStreak(CurrentStreakRef ref) {
  final statsAsync = ref.watch(statisticsProvider);
  
  return statsAsync.when(
    data: (stats) {
      if (stats.isEmpty) return 0;
      
      int streak = 0;
      var currentDate = DateTime.now();
      
      for (final stat in stats) {
        final statDate = DateTime.parse(stat.dateKey);
        final expectedDate = currentDate.subtract(Duration(days: streak));
        
        if (statDate.year == expectedDate.year &&
            statDate.month == expectedDate.month &&
            statDate.day == expectedDate.day) {
          if (stat.hasActivity) {
            streak++;
          } else {
            break;
          }
        }
      }
      
      return streak;
    },
    loading: () => 0,
    error: (_, __) => 0,
  );
}

// Longest streak
@riverpod
int longestStreak(LongestStreakRef ref) {
  final statsAsync = ref.watch(statisticsProvider);
  
  return statsAsync.when(
    data: (stats) {
      if (stats.isEmpty) return 0;
      
      int maxStreak = 0;
      int currentStreak = 0;
      
      final sortedStats = stats.toList()
        ..sort((a, b) => a.dateKey.compareTo(b.dateKey));
      
      for (final stat in sortedStats) {
        if (stat.hasActivity) {
          currentStreak++;
          maxStreak = max(maxStreak, currentStreak);
        } else {
          currentStreak = 0;
        }
      }
      
      return maxStreak;
    },
    loading: () => 0,
    error: (_, __) => 0,
  );
}

// Total statistics
@riverpod
Map<String, int> totalStatistics(TotalStatisticsRef ref) {
  final statsAsync = ref.watch(statisticsProvider);
  
  return statsAsync.when(
    data: (stats) {
      int totalCount = 0;
      int totalTime = 0;
      int totalTargets = 0;
      
      for (final stat in stats) {
        totalCount += stat.totalCount;
        totalTime += stat.totalTimeSeconds;
        totalTargets += stat.totalCompletedTargets;
      }
      
      return {
        'totalCount': totalCount,
        'totalTimeSeconds': totalTime,
        'totalTargets': totalTargets,
        'activeDays': stats.where((s) => s.hasActivity).length,
      };
    },
    loading: () => {'totalCount': 0, 'totalTimeSeconds': 0, 'totalTargets': 0, 'activeDays': 0},
    error: (_, __) => {'totalCount': 0, 'totalTimeSeconds': 0, 'totalTargets': 0, 'activeDays': 0},
  );
}

// Zikr-specific statistics
@riverpod
Future<Map<String, dynamic>> zikrStatistics(ZikrStatisticsRef ref, String zikrId) async {
  final repo = ref.watch(storageRepositoryProvider);
  await repo.initialize();
  
  final stats = await repo.getDailyStats();
  final zikr = await repo.getZikr(zikrId);
  
  if (zikr == null) return {};
  
  int totalCount = 0;
  int totalTime = 0;
  int completedTargets = 0;
  int activeDays = 0;
  
  for (final stat in stats) {
    totalCount += stat.zikrCounts[zikrId] ?? 0;
    totalTime += stat.zikrTimeSeconds[zikrId] ?? 0;
    completedTargets += stat.completedTargets[zikrId] ?? 0;
    if ((stat.zikrCounts[zikrId] ?? 0) > 0) activeDays++;
  }
  
  return {
    'totalCount': totalCount,
    'totalTimeSeconds': totalTime,
    'completedTargets': completedTargets,
    'activeDays': activeDays,
    'currentCount': zikr.currentCount,
    'totalCountAllTime': zikr.totalCount,
    'targetCount': zikr.targetCount,
    'practiceTimeSeconds': zikr.practiceTimeSeconds,
  };
}