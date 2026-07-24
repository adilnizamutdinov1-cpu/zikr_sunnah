// Riverpod-провайдеры. Единственный источник правды для зикров —
// ZikrListNotifier (держит List<Zikr> и синхронизирует с Hive).
// activeZikrProvider и счётчик выводятся из него реактивно.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/models/models.dart';
import '../../core/storage/storage.dart';

final _uuid = const Uuid();

// ──────────────────────────────────────────────────────────────────────────
// Репозиторий и инициализация
// ──────────────────────────────────────────────────────────────────────────
final storageRepositoryProvider = Provider<IStorageRepository>(
  (ref) => HiveStorageRepository.instance,
);

/// true, когда Hive-боксы открыты и сид-данные заложены.
final storageReadyProvider = FutureProvider<bool>((ref) async {
  final repo = ref.read(storageRepositoryProvider);
  await repo.init();
  if (repo.getZikrs().isEmpty) {
    for (final z in SunnahAzkar.seed()) {
      await repo.saveZikr(z);
    }
    await repo.setActiveZikrId('sunnah_subhanallah');
  }
  return true;
});

// ──────────────────────────────────────────────────────────────────────────
// Настройки
// ──────────────────────────────────────────────────────────────────────────
class SettingsNotifier extends StateNotifier<AppSettings> {
  final IStorageRepository _repo;
  SettingsNotifier(this._repo) : super(_repo.getSettings());

  Future<void> update(AppSettings settings) async {
    state = settings;
    await _repo.saveSettings(settings);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  ref.watch(storageReadyProvider);
  return SettingsNotifier(ref.read(storageRepositoryProvider));
});

// ──────────────────────────────────────────────────────────────────────────
// Список зикров — единственный источник правды
// ──────────────────────────────────────────────────────────────────────────
class ZikrListNotifier extends StateNotifier<List<Zikr>> {
  final IStorageRepository _repo;
  ZikrListNotifier(this._repo) : super(_repo.getZikrs());

  void _save(Zikr z) {
    _repo.saveZikr(z);
    state = [
      for (final e in state)
        if (e.id == z.id) z else e,
    ];
  }

  Future<Zikr> addZikr({
    required String name,
    required String arabicText,
    required String transliteration,
    required String translation,
    required int targetCount,
    int step = 1,
    int colorValue = 0xFFD4A843,
  }) async {
    final now = DateTime.now();
    final zikr = Zikr(
      id: 'personal_${_uuid.v4()}',
      name: name,
      arabicText: arabicText,
      transliteration: transliteration,
      translation: translation,
      targetCount: targetCount,
      currentCount: 0,
      totalCount: 0,
      step: step,
      practiceTimeSeconds: 0,
      colorValue: colorValue,
      category: ZikrCategory.personal,
      createdAt: now,
      updatedAt: now,
    );
    await _repo.saveZikr(zikr);
    state = [...state, zikr];
    return zikr;
  }

  Future<void> updateZikr(Zikr zikr) async => _save(zikr);

  Future<void> deleteZikr(String id) async {
    await _repo.deleteZikr(id);
    state = state.where((z) => z.id != id).toList();
  }

  Future<Zikr> duplicateZikr(Zikr src) async {
    final now = DateTime.now();
    final copy = src.copyWith(
      id: 'personal_${_uuid.v4()}',
      name: '${src.name} (копия)',
      currentCount: 0,
      totalCount: 0,
      practiceTimeSeconds: 0,
      category: ZikrCategory.personal,
      createdAt: now,
      updatedAt: now,
    );
    await _repo.saveZikr(copy);
    state = [...state, copy];
    return copy;
  }

  // ── Операции счётчика для конкретного зикра ──────────────────────────────

  /// Увеличить счёт. Возвращает true, если в результате достигнута цель.
  bool increment(String id, {int? by}) {
    final idx = state.indexWhere((z) => z.id == id);
    if (idx == -1) return false;
    final z = state[idx];
    final step = by ?? z.step;
    final before = z.currentCount;
    final updated = z.withIncrement(step);
    _save(updated);
    _recordDaily(step, 0);
    return before < z.targetCount && updated.currentCount >= z.targetCount;
  }

  void setCount(String id, int count) {
    final idx = state.indexWhere((z) => z.id == id);
    if (idx == -1) return;
    _save(state[idx].withManualCount(count));
  }

  void setTarget(String id, int target) {
    final idx = state.indexWhere((z) => z.id == id);
    if (idx == -1) return;
    _save(state[idx].withNewTarget(target));
  }

  void setStep(String id, int step) {
    final idx = state.indexWhere((z) => z.id == id);
    if (idx == -1) return;
    _save(state[idx].withStep(step));
  }

  /// Сбросить текущий счёт, вернуть предыдущее значение (для undo).
  int resetCurrent(String id) {
    final idx = state.indexWhere((z) => z.id == id);
    if (idx == -1) return 0;
    final prev = state[idx].currentCount;
    _save(state[idx].resetCurrentCount());
    return prev;
  }

  void restoreCount(String id, int count) {
    final idx = state.indexWhere((z) => z.id == id);
    if (idx == -1) return;
    _save(state[idx].copyWith(currentCount: count));
  }

  void addPracticeTime(String id, int seconds) {
    final idx = state.indexWhere((z) => z.id == id);
    if (idx == -1) return;
    _save(state[idx].addPracticeTime(seconds));
    _recordDaily(0, seconds);
  }

  void _recordDaily(int count, int seconds) {
    final key = _todayKey();
    final existing = _repo.getDailyStat(key);
    final stat = DailyStat(
      dateKey: key,
      totalCount: (existing?.totalCount ?? 0) + count,
      practiceSeconds: (existing?.practiceSeconds ?? 0) + seconds,
      updatedAt: DateTime.now(),
    );
    _repo.upsertDailyStat(stat);
  }

  String _todayKey() {
    final d = DateTime.now();
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }
}

final zikrListProvider =
    StateNotifierProvider<ZikrListNotifier, List<Zikr>>((ref) {
  ref.watch(storageReadyProvider);
  return ZikrListNotifier(ref.read(storageRepositoryProvider));
});

// ──────────────────────────────────────────────────────────────────────────
// Активный зикр
// ──────────────────────────────────────────────────────────────────────────
class ActiveZikrNotifier extends StateNotifier<String?> {
  final IStorageRepository _repo;
  final Ref _ref;
  ActiveZikrNotifier(this._repo, this._ref) : super(_resolveInitial(_repo, _ref));

  static String? _resolveInitial(IStorageRepository repo, Ref ref) {
    var id = repo.getActiveZikrId();
    final zikrs = repo.getZikrs();
    if (id == null || zikrs.every((z) => z.id != id)) {
      id = zikrs.isNotEmpty ? zikrs.first.id : null;
    }
    return id;
  }

  Future<void> set(String id) async {
    state = id;
    await _repo.setActiveZikrId(id);
  }

  Future<void> switchTo(bool forward) async {
    final list = _ref.read(zikrListProvider);
    if (list.isEmpty) return;
    final idx = list.indexWhere((z) => z.id == state);
    if (idx == -1) {
      await set(list.first.id);
      return;
    }
    final next = forward
        ? (idx + 1) % list.length
        : (idx - 1 + list.length) % list.length;
    await set(list[next].id);
  }
}

final activeZikrIdProvider =
    StateNotifierProvider<ActiveZikrNotifier, String?>((ref) {
  ref.watch(storageReadyProvider);
  return ActiveZikrNotifier(ref.read(storageRepositoryProvider), ref);
});

/// Полный объект активного зикра (реактивно).
final activeZikrProvider = Provider<Zikr?>((ref) {
  final id = ref.watch(activeZikrIdProvider);
  final list = ref.watch(zikrListProvider);
  if (id == null) return null;
  for (final z in list) {
    if (z.id == id) return z;
  }
  return list.isNotEmpty ? list.first : null;
});

// ──────────────────────────────────────────────────────────────────────────
// Ежедневная статистика, серия дней, агрегаты
// ──────────────────────────────────────────────────────────────────────────
final dailyStatsProvider = Provider<List<DailyStat>>((ref) {
  ref.watch(storageReadyProvider);
  // пересчитывается при любом изменении списка зикров (запись статистики)
  ref.watch(zikrListProvider);
  return ref.read(storageRepositoryProvider).getDailyStats();
});

final currentStreakProvider = Provider<int>((ref) {
  final stats = ref.watch(dailyStatsProvider);
  if (stats.isEmpty) return 0;
  final activeDays =
      stats.where((s) => s.totalCount > 0).map((s) => _dateOnly(s.date)).toSet();
  var streak = 0;
  var day = _dateOnly(DateTime.now());
  if (!activeDays.contains(day)) {
    day = day.subtract(const Duration(days: 1));
    if (!activeDays.contains(day)) return 0;
  }
  while (activeDays.contains(day)) {
    streak++;
    day = day.subtract(const Duration(days: 1));
  }
  return streak;
});

class StatsSummary {
  final int today;
  final int week;
  final int month;
  final int allTime;
  final int practiceSecondsToday;
  const StatsSummary({
    required this.today,
    required this.week,
    required this.month,
    required this.allTime,
    required this.practiceSecondsToday,
  });
}

final statsSummaryProvider = Provider<StatsSummary>((ref) {
  final stats = ref.watch(dailyStatsProvider);
  final now = DateTime.now();
  final today = _dateOnly(now);
  final weekStart = today.subtract(Duration(days: now.weekday - 1));
  final monthStart = DateTime(now.year, now.month, 1);

  int todayCount = 0, weekCount = 0, monthCount = 0, allCount = 0, todaySec = 0;
  for (final s in stats) {
    allCount += s.totalCount;
    final d = _dateOnly(s.date);
    if (d == today) {
      todayCount += s.totalCount;
      todaySec += s.practiceSeconds;
    }
    if (!d.isBefore(weekStart)) weekCount += s.totalCount;
    if (!d.isBefore(monthStart)) monthCount += s.totalCount;
  }
  return StatsSummary(
    today: todayCount,
    week: weekCount,
    month: monthCount,
    allTime: allCount,
    practiceSecondsToday: todaySec,
  );
});

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

// ──────────────────────────────────────────────────────────────────────────
// Резервное копирование
// ──────────────────────────────────────────────────────────────────────────
final backupProvider = Provider<BackupActions>((ref) {
  ref.watch(storageReadyProvider);
  final repo = ref.read(storageRepositoryProvider) as HiveStorageRepository;
  return BackupActions(repo, ref);
});

class BackupActions {
  final HiveStorageRepository _repo;
  final Ref _ref;
  BackupActions(this._repo, this._ref);

  BackupData exportData() => _repo.snapshot();

  Future<void> importData(BackupData backup) async {
    await _repo.restoreAll(backup);
    _ref.invalidate(settingsProvider);
    _ref.invalidate(zikrListProvider);
    _ref.invalidate(activeZikrIdProvider);
    _ref.invalidate(dailyStatsProvider);
  }
}
