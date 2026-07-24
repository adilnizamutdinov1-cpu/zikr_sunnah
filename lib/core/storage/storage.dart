// Хранилище данных на Hive. Хранит Maps — без TypeAdapter-ов и codegen.
// После каждого нажатия данные сразу пишутся на диск (await box.put),
// поэтому после закрытия/перезагрузки счёт сохраняется точно.

import 'package:hive_flutter/hive_flutter.dart';

import '../models/models.dart';

/// Интерфейс репозитория (для возможности замены бэкенда).
abstract class IStorageRepository {
  Future<void> init();
  List<Zikr> getZikrs();
  Zikr? getZikr(String id);
  Future<void> saveZikr(Zikr zikr);
  Future<void> deleteZikr(String id);
  String? getActiveZikrId();
  Future<void> setActiveZikrId(String id);
  AppSettings getSettings();
  Future<void> saveSettings(AppSettings settings);
  List<DailyStat> getDailyStats();
  DailyStat? getDailyStat(String dateKey);
  Future<void> upsertDailyStat(DailyStat stat);
  Future<void> clearAll();
}

const _kZikrsBox = 'zikrs';
const _kSettingsBox = 'settings';
const _kStatsBox = 'daily_stats';
const _kMetaBox = 'meta';
const _kActiveZikrKey = 'active_zikr_id';
const _kSettingsKey = 'app_settings';

class HiveStorageRepository implements IStorageRepository {
  HiveStorageRepository._();
  static final HiveStorageRepository instance = HiveStorageRepository._();

  late Box<Map> _zikrs;
  late Box<Map> _settings;
  late Box<Map> _stats;
  late Box _meta;

  @override
  Future<void> init() async {
    await Hive.initFlutter();
    _zikrs = await Hive.openBox<Map>(_kZikrsBox);
    _settings = await Hive.openBox<Map>(_kSettingsBox);
    _stats = await Hive.openBox<Map>(_kStatsBox);
    _meta = await Hive.openBox(_kMetaBox);
  }

  // ── Zikrs ───────────────────────────────────────────────────────────────
  @override
  List<Zikr> getZikrs() {
    final list = _zikrs.values
        .map((e) => Zikr.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  @override
  Zikr? getZikr(String id) {
    final raw = _zikrs.get(id);
    if (raw == null) return null;
    return Zikr.fromMap(Map<String, dynamic>.from(raw));
  }

  @override
  Future<void> saveZikr(Zikr zikr) async {
    await _zikrs.put(zikr.id, zikr.toMap());
  }

  @override
  Future<void> deleteZikr(String id) async {
    await _zikrs.delete(id);
  }

  // ── Active zikr ─────────────────────────────────────────────────────────
  @override
  String? getActiveZikrId() => _meta.get(_kActiveZikrKey) as String?;

  @override
  Future<void> setActiveZikrId(String id) =>
      _meta.put(_kActiveZikrKey, id);

  // ── Settings ────────────────────────────────────────────────────────────
  @override
  AppSettings getSettings() {
    final raw = _settings.get(_kSettingsKey);
    if (raw == null) return const AppSettings();
    return AppSettings.fromMap(Map<String, dynamic>.from(raw));
  }

  @override
  Future<void> saveSettings(AppSettings settings) =>
      _settings.put(_kSettingsKey, settings.toMap());

  // ── Daily stats ─────────────────────────────────────────────────────────
  @override
  List<DailyStat> getDailyStats() {
    final list = _stats.values
        .map((e) => DailyStat.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    list.sort((a, b) => a.dateKey.compareTo(b.dateKey));
    return list;
  }

  @override
  DailyStat? getDailyStat(String dateKey) {
    final raw = _stats.get(dateKey);
    if (raw == null) return null;
    return DailyStat.fromMap(Map<String, dynamic>.from(raw));
  }

  @override
  Future<void> upsertDailyStat(DailyStat stat) =>
      _stats.put(stat.dateKey, stat.toMap());

  @override
  Future<void> clearAll() async {
    await _zikrs.clear();
    await _stats.clear();
    await _meta.clear();
  }

  /// Полная замена всех данных (используется при импорте резервной копии).
  Future<void> restoreAll(BackupData backup) async {
    await _zikrs.clear();
    for (final z in backup.zikrs) {
      await _zikrs.put(z.id, z.toMap());
    }
    await _stats.clear();
    for (final d in backup.dailyStats) {
      await _stats.put(d.dateKey, d.toMap());
    }
    await _settings.put(_kSettingsKey, backup.settings.toMap());
    if (backup.activeZikrId.isNotEmpty) {
      await _meta.put(_kActiveZikrKey, backup.activeZikrId);
    }
  }

  BackupData snapshot() => BackupData(
        version: '1.0.0',
        exportedAt: DateTime.now(),
        zikrs: getZikrs(),
        settings: getSettings(),
        dailyStats: getDailyStats(),
        activeZikrId: getActiveZikrId() ?? '',
      );
}
