// Storage Layer - Hive Repositories
// Provides local persistence for Zikr, Settings, Statistics, and Sessions

import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'zikr_models.dart';
import 'hive_boxes.dart';

part 'storage_repository.g.dart';

// ============================================
// BOX NAMES
// ============================================
class HiveBoxes {
  static const String zikrs = 'zikrs';
  static const String settings = 'settings';
  static const String dailyStats = 'daily_stats';
  static const String sessions = 'sessions';
}

// ============================================
// STORAGE REPOSITORY INTERFACE
// ============================================
abstract class IStorageRepository {
  Future<void> initialize();
  
  // Zikrs
  Future<List<Zikr>> getAllZikrs();
  Future<Zikr?> getZikr(String id);
  Future<void> saveZikr(Zikr zikr);
  Future<void> saveAllZikrs(List<Zikr> zikrs);
  Future<void> deleteZikr(String id);
  Future<void> initializeDefaultZikrs();
  
  // Active Zikr
  Future<String?> getActiveZikrId();
  Future<void> setActiveZikrId(String id);
  
  // Settings
  Future<AppSettings> getSettings();
  Future<void> saveSettings(AppSettings settings);
  
  // Daily Stats
  Future<DailyStat?> getDailyStat(String dateKey);
  Future<List<DailyStat>> getDailyStats({DateTime? start, DateTime? end});
  Future<void> saveDailyStat(DailyStat stat);
  Future<void> incrementDailyCount(String zikrId, int count, int timeSeconds);
  Future<void> incrementCompletedTarget(String zikrId);
  
  // Sessions (for undo)
  Future<void> saveSession(ZikrSession session);
  Future<List<ZikrSession>> getRecentSessions({int limit = 50});
  Future<ZikrSession?> getLastSessionOfType(String zikrId, SessionType type);
  
  // Backup
  Future<BackupData> createBackup();
  Future<void> restoreBackup(BackupData backup);
  Future<void> clearAllData();
}

class HiveStorageRepository implements IStorageRepository {
  late Box<Zikr> _zikrBox;
  late Box<AppSettings> _settingsBox;
  late Box<DailyStat> _dailyStatBox;
  late Box<ZikrSession> _sessionBox;
  late Box<String> _metaBox;
  
  static const String _activeZikrKey = 'active_zikr_id';
  static const String _initializedKey = 'default_zikrs_initialized';
  
  @override
  Future<void> initialize() async {
    final appDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDir.path);
    
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(ZikrAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(AppSettingsAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(DailyStatAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(ZikrSessionAdapter());
    if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(BackupDataAdapter());
    if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(ZikrCategoryAdapter());
    if (!Hive.isAdapterRegistered(6)) Hive.registerAdapter(ThemeModeAdapter());
    if (!Hive.isAdapterRegistered(7)) Hive.registerAdapter(HapticIntensityAdapter());
    if (!Hive.isAdapterRegistered(8)) Hive.registerAdapter(NumberFormatTypeAdapter());
    if (!Hive.isAdapterRegistered(9)) Hive.registerAdapter(SessionTypeAdapter());
    
    // Open boxes
    _zikrBox = await Hive.openBox<Zikr>(HiveBoxes.zikrs);
    _settingsBox = await Hive.openBox<AppSettings>(HiveBoxes.settings);
    _dailyStatBox = await Hive.openBox<DailyStat>(HiveBoxes.dailyStats);
    _sessionBox = await Hive.openBox<ZikrSession>(HiveBoxes.sessions);
    _metaBox = await Hive.openBox<String>('meta');
    
    // Initialize defaults if needed
    if (!_metaBox.containsKey('default_zikrs_initialized')) {
      await initializeDefaultZikrs();
      await _metaBox.put('default_zikrs_initialized', 'true');
    }
    
    // Ensure active zikr is set
    if (!_metaBox.containsKey('active_zikr_id')) {
      final zikrs = _zikrBox.values.toList();
      if (zikrs.isNotEmpty) {
        await _metaBox.put('active_zikr_id', zikrs.first.id);
      }
    }
  }
  
  // ============================================
  // ZIKRS
  // ============================================
  @override
  Future<List<Zikr>> getAllZikrs() async {
    return _zikrBox.values.toList()..sort((a, b) {
      if (a.category != b.category) {
        return a.category == ZikrCategory.sunnahAzkar ? -1 : 1;
      }
      return a.createdAt.compareTo(b.createdAt);
    });
  }
  
  @override
  Future<Zikr?> getZikr(String id) async {
    return _zikrBox.get(id);
  }
  
  @override
  Future<void> saveZikr(Zikr zikr) async {
    await _zikrBox.put(zikr.id, zikr);
  }
  
  @override
  Future<void> saveAllZikrs(List<Zikr> zikrs) async {
    final map = {for (var z in zikrs) z.id: z};
    await _zikrBox.putAll(map);
  }
  
  @override
  Future<void> deleteZikr(String id) async {
    await _zikrBox.delete(id);
    // If deleted zikr was active, select first available
    final activeId = _metaBox.get('active_zikr_id');
    if (activeId == id) {
      final remaining = _zikrBox.values.toList();
      if (remaining.isNotEmpty) {
        await _metaBox.put('active_zikr_id', remaining.first.id);
      } else {
        await _metaBox.delete('active_zikr_id');
      }
    }
  }
  
  @override
  Future<void> initializeDefaultZikrs() async {
    final existing = _zikrBox.values.toList();
    if (existing.isNotEmpty) return;
    
    final defaultZikrs = SunnahAzkar.toZikrList();
    await saveAllZikrs(defaultZikrs);
    
    if (defaultZikrs.isNotEmpty) {
      await _metaBox.put('active_zikr_id', defaultZikrs.first.id);
    }
  }
  
  // ============================================
  // ACTIVE ZIKR
  // ============================================
  @override
  Future<String?> getActiveZikrId() async {
    return _metaBox.get('active_zikr_id');
  }
  
  @override
  Future<void> setActiveZikrId(String id) async {
    await _metaBox.put('active_zikr_id', id);
  }
  
  // ============================================
  // SETTINGS
  // ============================================
  @override
  Future<AppSettings> getSettings() async {
    return _settingsBox.get('app_settings') ?? const AppSettings();
  }
  
  @override
  Future<void> saveSettings(AppSettings settings) async {
    await _settingsBox.put('app_settings', settings);
  }
  
  // ============================================
  // DAILY STATS
  // ============================================
  String _dateKey(DateTime date) => 
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  
  @override
  Future<DailyStat?> getDailyStat(String dateKey) async {
    return _dailyStatBox.get(dateKey);
  }
  
  @override
  Future<List<DailyStat>> getDailyStats({DateTime? start, DateTime? end}) async {
    var stats = _dailyStatBox.values.toList();
    
    if (start != null) {
      final startKey = _dateKey(start);
      stats = stats.where((s) => s.dateKey.compareTo(startKey) >= 0).toList();
    }
    if (end != null) {
      final endKey = _dateKey(end);
      stats = stats.where((s) => s.dateKey.compareTo(endKey) <= 0).toList();
    }
    
    stats.sort((a, b) => b.dateKey.compareTo(a.dateKey));
    return stats;
  }
  
  @override
  Future<void> saveDailyStat(DailyStat stat) async {
    await _dailyStatBox.put(stat.dateKey, stat);
  }
  
  @override
  Future<void> incrementDailyCount(String zikrId, int count, int timeSeconds) async {
    final key = _dateKey(DateTime.now());
    var stat = _dailyStatBox.get(key) ?? DailyStat(
      dateKey: key,
      zikrCounts: {},
      zikrTimeSeconds: {},
      completedTargets: {},
    );
    
    stat = stat.copyWith(
      zikrCounts: Map.from(stat.zikrCounts)..[zikrId] = (stat.zikrCounts[zikrId] ?? 0) + count,
      zikrTimeSeconds: Map.from(stat.zikrTimeSeconds)..[zikrId] = (stat.zikrTimeSeconds[zikrId] ?? 0) + timeSeconds,
      totalCount: stat.totalCount + count,
      totalTimeSeconds: stat.totalTimeSeconds + timeSeconds,
    );
    
    await _dailyStatBox.put(key, stat);
  }
  
  @override
  Future<void> incrementCompletedTarget(String zikrId) async {
    final key = _dateKey(DateTime.now());
    var stat = _dailyStatBox.get(key) ?? DailyStat(
      dateKey: key,
      zikrCounts: {},
      zikrTimeSeconds: {},
      completedTargets: {},
    );
    
    stat = stat.copyWith(
      completedTargets: Map.from(stat.completedTargets)..[zikrId] = (stat.completedTargets[zikrId] ?? 0) + 1,
      totalCompletedTargets: stat.totalCompletedTargets + 1,
    );
    
    await _dailyStatBox.put(key, stat);
  }
  
  // ============================================
  // SESSIONS
  // ============================================
  @override
  Future<void> saveSession(ZikrSession session) async {
    await _sessionBox.put(session.id, session);
    // Keep only last 1000 sessions
    if (_sessionBox.length > 1000) {
      final keys = _sessionBox.keys.cast<String>().toList()
        ..sort((a, b) {
          final sa = _sessionBox.get(a)!;
          final sb = _sessionBox.get(b)!;
          return sa.timestamp.compareTo(sb.timestamp);
        });
      await _sessionBox.delete(keys.first);
    }
  }
  
  @override
  Future<List<ZikrSession>> getRecentSessions({int limit = 50}) async {
    final sessions = _sessionBox.values.toList();
    sessions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sessions.take(limit).toList();
  }
  
  @override
  Future<ZikrSession?> getLastSessionOfType(String zikrId, SessionType type) async {
    final sessions = _sessionBox.values
        .where((s) => s.zikrId == zikrId && s.type == type)
        .toList();
    if (sessions.isEmpty) return null;
    sessions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sessions.first;
  }
  
  // ============================================
  // BACKUP
  // ============================================
  @override
  Future<BackupData> createBackup() async {
    final zikrs = await getAllZikrs();
    final settings = await getSettings();
    final stats = await getDailyStats();
    final recentSessions = <ZikrSession>[];
    
    final sessionKeys = _sessionBox.keys.cast<String>().toList()
      ..sort((a, b) {
        final sa = _sessionBox.get(a)!;
        final sb = _sessionBox.get(b)!;
        return sb.timestamp.compareTo(sa.timestamp);
      });
    
    for (final key in sessionKeys.take(100)) {
      final session = _sessionBox.get(key);
      if (session != null) recentSessions.add(session);
    }
    
    return BackupData(
      version: '1.0.0',
      exportedAt: DateTime.now(),
      zikrs: zikrs,
      settings: settings,
      dailyStats: stats,
      recentSessions: recentSessions,
    );
  }
  
  @override
  Future<void> restoreBackup(BackupData backup) async {
    await _zikrBox.clear();
    await _settingsBox.clear();
    await _dailyStatBox.clear();
    await _sessionBox.clear();
    await _metaBox.clear();
    
    for (final zikr in backup.zikrs) {
      await _zikrBox.put(zikr.id, zikr);
    }
    await _settingsBox.put('app_settings', backup.settings);
    
    for (final stat in backup.dailyStats) {
      await _dailyStatBox.put(stat.dateKey, stat);
    }
    
    for (final session in backup.recentSessions) {
      await _sessionBox.put(session.id, session);
    }
    
    if (backup.zikrs.isNotEmpty) {
      await _metaBox.put('active_zikr_id', backup.zikrs.first.id);
    }
    await _metaBox.put('default_zikrs_initialized', 'true');
  }
  
  @override
  Future<void> clearAllData() async {
    await _zikrBox.clear();
    await _settingsBox.clear();
    await _dailyStatBox.clear();
    await _sessionBox.clear();
    await _metaBox.clear();
    await initializeDefaultZikrs();
  }
}

@riverpod
IStorageRepository storageRepository(StorageRepositoryRef ref) {
  return HiveStorageRepository();
}

@riverpod
Future<void> initializeStorage(InitializeStorageRef ref) async {
  final repo = ref.watch(storageRepositoryProvider);
  await repo.initialize();
}