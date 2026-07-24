// Storage Repository Implementation
// Handles all local data operations with Hive

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';

import 'zikr_models.dart';
import 'hive_adapters.dart';

part 'storage_repository.g.dart';

// ============================================
// BOX NAMES
// ============================================
const String _zikrBoxName = 'zikrs';
const String _settingsBoxName = 'settings';
const String _dailyStatBoxName = 'daily_stats';
const String _sessionBoxName = 'sessions';
const String _metaBoxName = 'meta';

// ============================================
// STORAGE REPOSITORY INTERFACE
// ============================================
abstract class StorageRepository {
  Future<void> initialize();
  
  // Zikr operations
  Future<List<Zikr>> getAllZikrs();
  Future<Zikr?> getZikr(String id);
  Future<void> saveZikr(Zikr zikr);
  Future<void> deleteZikr(String id);
  Future<void> initializeDefaultZikrs();
  
  // Active zikr
  Future<String?> getActiveZikrId();
  Future<void> setActiveZikrId(String zikrId);
  
  // Settings
  Future<AppSettings> getSettings();
  Future<void> saveSettings(AppSettings settings);
  
  // Daily statistics
  Future<DailyStat?> getDailyStat(String dateKey);
  Future<List<DailyStat>> getDailyStats({DateTime? from, DateTime? to});
  Future<void> incrementDailyStat(String dateKey, String zikrId, int count, int seconds);
  Future<void> addCompletedTarget(String dateKey, String zikrId);
  
  // Sessions (for undo)
  Future<void> addSession(ZikrSession session);
  Future<ZikrSession?> getLastSession();
  Future<void> clearOldSessions({int maxAgeDays = 30});
  
  // Backup
  Future<BackupData> createBackup();
  Future<void> restoreBackup(BackupData backup);
  Future<void> exportBackupToFile();
  Future<void> importBackupFromFile();
  
  // Maintenance
  Future<void> clearAllData();
}

// ============================================
// HIVE STORAGE REPOSITORY IMPLEMENTATION
// ============================================
class HiveStorageRepository implements StorageRepository {
  late Box<Zikr> _zikrBox;
  late Box<AppSettings> _settingsBox;
  late Box<DailyStat> _dailyStatBox;
  late Box<ZikrSession> _sessionBox;
  late Box _metaBox;
  
  bool _initialized = false;
  
  @override
  Future<void> initialize() async {
    if (_initialized) return;
    
    // Initialize Hive
    final appDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDir.path);
    
    // Register adapters
    _registerAdapters();
    
    // Open boxes
    _zikrBox = await Hive.openBox<Zikr>(_zikrBoxName);
    _settingsBox = await Hive.openBox<AppSettings>(_settingsBoxName);
    _dailyStatBox = await Hive.openBox<DailyStat>(_dailyStatBoxName);
    _sessionBox = await Hive.openBox<ZikrSession>(_sessionBoxName);
    _metaBox = await Hive.openBox(_metaBoxName);
    
    // Initialize defaults if needed
    await _ensureDefaults();
    
    _initialized = true;
  }
  
  void _registerAdapters() {
    Hive
      ..registerAdapter(ZikrAdapter())
      ..registerAdapter(AppSettingsAdapter())
      ..registerAdapter(DailyStatAdapter())
      ..registerAdapter(ZikrSessionAdapter())
      ..registerAdapter(BackupDataAdapter())
      ..registerAdapter(ZikrCategoryAdapter())
      ..registerAdapter(ThemeModeAdapter())
      ..registerAdapter(HapticIntensityAdapter())
      ..registerAdapter(NumberFormatTypeAdapter())
      ..registerAdapter(SessionTypeAdapter());
  }
  
  Future<void> _ensureDefaults() async {
    // Default settings
    if (!_settingsBox.containsKey('settings')) {
      await _settingsBox.put('settings', AppSettings.defaultSettings);
    }
    
    // Default active zikr
    if (!_metaBox.containsKey('active_zikr_id')) {
      final defaultZikr = _zikrBox.values.firstOrNull;
      if (defaultZikr != null) {
        await _metaBox.put('active_zikr_id', defaultZikr.id);
      }
    }
    
    // Initialize default zikrs if empty
    if (_zikrBox.isEmpty) {
      await initializeDefaultZikrs();
    }
  }
  
  // ============================================
  // ZIKR OPERATIONS
  // ============================================
  
  @override
  Future<List<Zikr>> getAllZikrs() async {
    return _zikrBox.values.toList()
      ..sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
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
  Future<void> deleteZikr(String id) async {
    await _zikrBox.delete(id);
    
    // If deleted zikr was active, switch to another
    final activeId = await getActiveZikrId();
    if (activeId == id) {
      final remaining = _zikrBox.values.firstOrNull;
      if (remaining != null) {
        await setActiveZikrId(remaining.id);
      } else {
        await _metaBox.delete('active_zikr_id');
      }
    }
  }
  
  @override
  Future<void> initializeDefaultZikrs() async {
    for (final azkarData in SunnahAzkar.azkar) {
      final zikr = Zikr(
        id: azkarData['id'] as String,
        name: azkarData['name'] as String,
        arabicText: azkarData['arabic'] as String,
        transliteration: azkarData['transliteration'] as String,
        translation: azkarData['translation'] as String,
        targetCount: azkarData['target'] as int,
        currentCount: 0,
        totalCount: 0,
        practiceTimeSeconds: 0,
        colorValue: azkarData['color'] as int,
        category: ZikrCategory.sunnahAzkar,
        source: azkarData['source'] as String,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        warningThreshold: null,
        autoResetOnTarget: false,
      );
      await _zikrBox.put(zikr.id, zikr);
    }
    
    // Set first as active
    final first = SunnahAzkar.azkar.first['id'] as String;
    await setActiveZikrId(first);
  }
  
  // ============================================
  // ACTIVE ZIKR
  // ============================================
  
  @override
  Future<String?> getActiveZikrId() async {
    return _metaBox.get('active_zikr_id') as String?;
  }
  
  @override
  Future<void> setActiveZikrId(String zikrId) async {
    await _metaBox.put('active_zikr_id', zikrId);
  }
  
  // ============================================
  // SETTINGS
  // ============================================
  
  @override
  Future<AppSettings> getSettings() async {
    return _settingsBox.get('settings') ?? AppSettings.defaultSettings;
  }
  
  @override
  Future<void> saveSettings(AppSettings settings) async {
    await _settingsBox.put('settings', settings);
  }
  
  // ============================================
  // DAILY STATISTICS
  // ============================================
  
  String _dateKey(DateTime date) => 
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  
  @override
  Future<DailyStat?> getDailyStat(String dateKey) async {
    return _dailyStatBox.get(dateKey);
  }
  
  @override
  Future<List<DailyStat>> getDailyStats({DateTime? from, DateTime? to}) async {
    final stats = _dailyStatBox.values.toList();
    
    if (from != null) {
      final fromKey = _dateKey(from);
      stats.removeWhere((s) => s.dateKey.compareTo(fromKey) < 0);
    }
    if (to != null) {
      final toKey = _dateKey(to);
      stats.removeWhere((s) => s.dateKey.compareTo(toKey) > 0);
    }
    
    stats.sort((a, b) => b.dateKey.compareTo(a.dateKey));
    return stats;
  }
  
  @override
  Future<void> incrementDailyStat(String dateKey, String zikrId, int count, int seconds) async {
    var stat = _dailyStatBox.get(dateKey);
    
    if (stat == null) {
      stat = DailyStat(
        dateKey: dateKey,
        zikrCounts: {zikrId: count},
        zikrTimeSeconds: {zikrId: seconds},
        completedTargets: {},
        totalCount: count,
        totalTimeSeconds: seconds,
        totalCompletedTargets: 0,
      );
    } else {
      final zikrCounts = Map<String, int>.from(stat.zikrCounts);
      zikrCounts[zikrId] = (zikrCounts[zikrId] ?? 0) + count;
      
      final zikrTime = Map<String, int>.from(stat.zikrTimeSeconds);
      zikrTime[zikrId] = (zikrTime[zikrId] ?? 0) + seconds;
      
      stat = stat.copyWith(
        zikrCounts: zikrCounts,
        zikrTimeSeconds: zikrTime,
        totalCount: stat.totalCount + count,
        totalTimeSeconds: stat.totalTimeSeconds + seconds,
      );
    }
    
    await _dailyStatBox.put(dateKey, stat);
  }
  
  @override
  Future<void> addCompletedTarget(String dateKey, String zikrId) async {
    var stat = _dailyStatBox.get(dateKey);
    
    if (stat == null) {
      stat = DailyStat(
        dateKey: dateKey,
        zikrCounts: {},
        zikrTimeSeconds: {},
        completedTargets: {zikrId: 1},
        totalCount: 0,
        totalTimeSeconds: 0,
        totalCompletedTargets: 1,
      );
    } else {
      final completed = Map<String, int>.from(stat.completedTargets);
      completed[zikrId] = (completed[zikrId] ?? 0) + 1;
      
      stat = stat.copyWith(
        completedTargets: completed,
        totalCompletedTargets: stat.totalCompletedTargets + 1,
      );
    }
    
    await _dailyStatBox.put(dateKey, stat);
  }
  
  // ============================================
  // SESSIONS
  // ============================================
  
  @override
  Future<void> addSession(ZikrSession session) async {
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
  Future<ZikrSession?> getLastSession() async {
    if (_sessionBox.isEmpty) return null;
    
    final keys = _sessionBox.keys.cast<String>().toList()
      ..sort((a, b) {
        final sa = _sessionBox.get(a)!;
        final sb = _sessionBox.get(b)!;
        return sb.timestamp.compareTo(sa.timestamp);
      });
    
    return _sessionBox.get(keys.first);
  }
  
  @override
  Future<void> clearOldSessions({int maxAgeDays = 30}) async {
    final cutoff = DateTime.now().subtract(Duration(days: maxAgeDays));
    final toDelete = <String>[];
    
    for (final entry in _sessionBox.entries) {
      if (entry.value.timestamp.isBefore(cutoff)) {
        toDelete.add(entry.key as String);
      }
    }
    
    await _sessionBox.deleteAll(toDelete);
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
    // Clear existing data
    await _zikrBox.clear();
    await _settingsBox.clear();
    await _dailyStatBox.clear();
    await _sessionBox.clear();
    await _metaBox.clear();
    
    // Restore zikrs
    for (final zikr in backup.zikrs) {
      await _zikrBox.put(zikr.id, zikr);
    }
    
    // Restore settings
    await _settingsBox.put('settings', backup.settings);
    
    // Restore stats
    for (final stat in backup.dailyStats) {
      await _dailyStatBox.put(stat.dateKey, stat);
    }
    
    // Restore sessions
    for (final session in backup.recentSessions) {
      await _sessionBox.put(session.id, session);
    }
    
    // Set active zikr
    if (backup.zikrs.isNotEmpty) {
      await _metaBox.put('active_zikr_id', backup.zikrs.first.id);
    }
  }
  
  @override
  Future<void> exportBackupToFile() async {
    final backup = await createBackup();
    final jsonString = backup.toJson().toString();
    
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/zikr_backup_${DateTime.now().toIso8601String().replaceAll(':', '-')}.json');
    await file.writeAsString(jsonString);
    
    await Share.shareXFiles([XFile(file.path)], text: 'Резервная копия Зикр по Сунне');
  }
  
  @override
  Future<void> importBackupFromFile() async {
    // Implemented in UI layer with file_picker
    // This will be called with the selected file path
  }
  
  // ============================================
  // MAINTENANCE
  // ============================================
  
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

// ============================================
// RIVERPOD PROVIDERS
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