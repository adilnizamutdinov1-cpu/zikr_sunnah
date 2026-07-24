// Providers for State Management using Riverpod

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/models/zikr_models.dart';
import '../core/storage/storage_repository_impl.dart';

part 'zikr_providers.g.dart';

// ============================================
// STORAGE REPOSITORY
// ============================================
@riverpod
StorageRepository storageRepository(StorageRepositoryRef ref) {
  return HiveStorageRepository();
}

@riverpod
Future<void> initializeStorage(InitializeStorageRef ref) async {
  final repo = ref.watch(storageRepositoryProvider);
  await repo.initialize();
}

// ============================================
// SETTINGS
// ============================================
@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  @override
  Future<AppSettings> build() async {
    final repo = ref.watch(storageRepositoryProvider);
    await repo.initialize();
    return repo.getSettings();
  }

  Future<void> updateSettings(AppSettings settings) async {
    final repo = ref.read(storageRepositoryProvider);
    await repo.saveSettings(settings);
    state = AsyncValue.data(settings);
  }

  Future<void> toggleTheme() async {
    final current = state.value ?? AppSettings.defaultSettings;
    final newMode = switch (current.themeMode) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
      ThemeMode.system => ThemeMode.light,
    };
    await updateSettings(current.copyWith(themeMode: newMode));
  }
}

// ============================================
// ACTIVE ZIKR ID
// ============================================
@riverpod
class ActiveZikrIdNotifier extends _$ActiveZikrIdNotifier {
  @override
  String? build() {
    // Will be set after storage initialization
    return null;
  }

  void set(String id) {
    state = id;
  }
}

@riverpod
Future<String?> activeZikrIdFuture(ActiveZikrIdFutureRef ref) async {
  final repo = ref.watch(storageRepositoryProvider);
  await repo.initialize();
  return repo.getActiveZikrId();
}

// ============================================
// ALL ZIKRS
// ============================================
@riverpod
Stream<List<Zikr>> allZikrsStream(AllZikrsStreamRef ref) async* {
  final repo = ref.watch(storageRepositoryProvider);
  await repo.initialize();
  
  // Emit initial value
  yield await repo.getAllZikrs();
  
  // Listen for changes
  // Note: Hive doesn't have built-in streams, so we use a periodic timer or manual invalidation
  // For now, we'll rely on manual invalidation via ref.invalidate()
  // A proper implementation would use a ChangeNotifier wrapper around Hive boxes
  while (true) {
    await Future.delayed(const Duration(seconds: 1));
    // In a real app, you'd use Hive's watchable boxes or a StreamController
  }
}

@riverpod
Future<List<Zikr>> allZikrsFuture(AllZikrsFutureRef ref) async {
  final repo = ref.watch(storageRepositoryProvider);
  await repo.initialize();
  return repo.getAllZikrs();
}

// ============================================
// ACTIVE ZIKR
// ============================================
@riverpod
Future<Zikr?> activeZikrFuture(ActiveZikrFutureRef ref) async {
  final repo = ref.watch(storageRepositoryProvider);
  await repo.initialize();
  final activeId = await repo.getActiveZikrId();
  if (activeId == null) return null;
  return repo.getZikr(activeId);
}

@riverpod
Stream<Zikr?> activeZikrStream(ActiveZikrStreamRef ref) async* {
  final repo = ref.watch(storageRepositoryProvider);
  await repo.initialize();
  
  // Get initial
  final activeId = await repo.getActiveZikrId();
  if (activeId != null) {
    yield await repo.getZikr(activeId);
  }
  
  // For real-time updates, would need Hive streams
  while (true) {
    await Future.delayed(const Duration(seconds: 1));
  }
}

// ============================================
// ZIKR LIST PROVIDER (for switching)
// ============================================
@riverpod
class ZikrListNotifier extends _$ZikrListNotifier {
  @override
  List<Zikr> build() {
    return [];
  }

  void setList(List<Zikr> zikrs) {
    state = zikrs;
  }

  void switchZikr(bool forward) {
    if (state.isEmpty) return;
    
    final repo = ref.read(storageRepositoryProvider);
    final activeId = repo.getActiveZikrId();
    
    int currentIndex = state.indexWhere((z) => z.id == activeId);
    if (currentIndex == -1) currentIndex = 0;
    
    int newIndex;
    if (forward) {
      newIndex = (currentIndex + 1) % state.length;
    } else {
      newIndex = (currentIndex - 1 + state.length) % state.length;
    }
    
    final newZikr = state[newIndex];
    repo.setActiveZikrId(newZikr.id);
    ref.invalidate(activeZikrFutureProvider);
    ref.invalidate(activeZikrStreamProvider);
    ref.read(activeZikrIdNotifierProvider.notifier).set(newZikr.id);
  }
}

// ============================================
// COUNTER PROVIDER
// ============================================
@riverpod
class CounterNotifier extends _$CounterNotifier {
  @override
  Zikr build(String zikrId) {
    // This will be overridden by the family
    throw UnimplementedError('Use counterProvider(zikrId)');
  }
}

@riverpod
class CounterFamilyNotifier extends _$CounterFamilyNotifier {
  @override
  Zikr build(String zikrId) {
    // Initial value will be set by the first call
    // We return a placeholder that will be replaced
    return Zikr(
      id: zikrId,
      name: '',
      arabicText: '',
      transliteration: '',
      translation: '',
      targetCount: 100,
      currentCount: 0,
      totalCount: 0,
      practiceTimeSeconds: 0,
      colorValue: 0xFF006D5B,
      category: ZikrCategory.custom,
      source: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      warningThreshold: null,
      autoResetOnTarget: false,
    );
  }

  Future<void> _loadZikr(String zikrId) async {
    final repo = ref.read(storageRepositoryProvider);
    final zikr = await repo.getZikr(zikrId);
    if (zikr != null) {
      state = zikr;
    }
  }

  void increment({int by = 1}) {
    final repo = ref.read(storageRepositoryProvider);
    state = state.withIncrement(by);
    repo.saveZikr(state);
    
    // Update daily stats
    repo.incrementDailyStat(DateTime.now().toIso8601String().split('T').first, zikrId, by, 1);
    
    // Check if target reached
    if (state.isTargetReached && (state.currentCount - by) < state.targetCount) {
      repo.incrementCompletedTarget(DateTime.now().toIso8601String().split('T').first, zikrId);
    }
  }

  void decrement({int by = 1}) {
    final repo = ref.read(storageRepositoryProvider);
    state = state.withDecrement(by);
    repo.saveZikr(state);
  }

  void setCount(int count) {
    final repo = ref.read(storageRepositoryProvider);
    state = state.withManualCount(count);
    repo.saveZikr(state);
  }

  void resetCurrent() {
    final repo = ref.read(storageRepositoryProvider);
    state = state.resetCurrentCount();
    repo.saveZikr(state);
  }

  void continueCounting() {
    // Just continue - no reset
    final repo = ref.read(storageRepositoryProvider);
    repo.saveZikr(state);
  }

  void newRound() {
    final repo = ref.read(storageRepositoryProvider);
    state = state.resetCurrentCount();
    repo.saveZikr(state);
  }

  void addPracticeTime(int seconds) {
    final repo = ref.read(storageRepositoryProvider);
    state = state.addPracticeTime(seconds);
    repo.saveZikr(state);
  }
}

// ============================================
// DAILY STATS
// ============================================
@riverpod
Future<List<DailyStat>> dailyStatsFuture(DailyStatsFutureRef ref, 
  {DateTime? from, DateTime? to}) async {
  final repo = ref.watch(storageRepositoryProvider);
  await repo.initialize();
  return repo.getDailyStats(from: from, to: to);
}

// ============================================
// STREAK CALCULATION
// ============================================
@riverpod
Future<int> currentStreak(CurrentStreakRef ref) async {
  final repo = ref.watch(storageRepositoryProvider);
  await repo.initialize();
  
  final stats = await repo.getDailyStats();
  if (stats.isEmpty) return 0;
  
  stats.sort((a, b) => b.dateKey.compareTo(a.dateKey));
  
  int streak = 0;
  DateTime expectedDate = DateTime.now();
  
  for (final stat in stats) {
    final statDate = DateTime.parse(stat.dateKey);
    final expectedKey = expectedDate.toIso8601String().split('T').first;
    
    if (stat.dateKey == expectedKey && stat.hasActivity) {
      streak++;
      expectedDate = expectedDate.subtract(const Duration(days: 1));
    } else if (stat.dateKey == expectedKey && !stat.hasActivity) {
      break; // Missed a day
    } else if (stat.dateKey.compareTo(expectedKey) < 0) {
      // Past dates, continue checking
      continue;
    }
  }
  
  return streak;
}

// ============================================
// BACKUP PROVIDERS
// ============================================
@riverpod
Future<BackupData> createBackupFuture(CreateBackupFutureRef ref) async {
  final repo = ref.watch(storageRepositoryProvider);
  return repo.createBackup();
}

@riverpod
Future<void> restoreBackupFuture(RestoreBackupFutureRef ref, BackupData backup) async {
  final repo = ref.watch(storageRepositoryProvider);
  await repo.restoreBackup(backup);
  ref.invalidate(allZikrsFutureProvider);
  ref.invalidate(activeZikrFutureProvider);
  ref.invalidate(settingsProvider);
}