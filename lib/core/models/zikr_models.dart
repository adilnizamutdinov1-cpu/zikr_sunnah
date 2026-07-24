// Core Models for Zikr Sunnah App
// Generated with Freezed for immutability and Hive for local storage

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:collection/collection.dart';

part 'zikr_models.freezed.dart';
part 'zikr_models.g.dart';

// ============================================
// HIVE TYPE IDS (keep consistent)
// ============================================
@HiveType(typeId: 0)
enum ZikrCategory {
  @HiveField(0)
  sunnahAzkar,
  @HiveField(1)
  custom,
}

// ============================================
// ZIKR MODEL
// ============================================
@freezed
@HiveType(typeId: 1, adapterName: 'ZikrAdapter')
class Zikr with _$Zikr {
  const Zikr._();

  const factory Zikr({
    @HiveField(0) required String id,
    @HiveField(1) required String name,
    @HiveField(2) required String arabicText,
    @HiveField(3) required String transliteration,
    @HiveField(4) required String translation,
    @HiveField(5) required int targetCount,
    @HiveField(6) required int currentCount,
    @HiveField(7) required int totalCount,
    @HiveField(8) required int practiceTimeSeconds,
    @HiveField(9) required int colorValue,
    @HiveField(10) required ZikrCategory category,
    @HiveField(11) String? source,
    @HiveField(12) required DateTime createdAt,
    @HiveField(13) required DateTime updatedAt,
    @HiveField(14) int? warningThreshold,
    @HiveField(15) bool autoResetOnTarget,
  }) = _Zikr;

  factory Zikr.fromJson(Map<String, dynamic> json) => _$ZikrFromJson(json);

  // Default targets
  static const List<int> defaultTargets = [33, 100, 1000];

  // Computed properties
  double get progress => targetCount > 0 ? (currentCount / targetCount).clamp(0.0, 1.0) : 0.0;
  bool get isTargetReached => currentCount >= targetCount && targetCount > 0;
  int get completedTargets => targetCount > 0 ? (currentCount ~/ targetCount) : 0;
  int get remainingToTarget => targetCount > 0 ? (targetCount - currentCount).clamp(0, targetCount) : 0;
  bool get showWarning => warningThreshold != null && currentCount >= warningThreshold! && !isTargetReached;

  // Formatted counts
  String get formattedCurrentCount => _formatNumber(currentCount);
  String get formattedTotalCount => _formatNumber(totalCount);
  String get formattedTargetCount => _formatNumber(targetCount);

  String _formatNumber(int number) {
    final str = number.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      buffer.write(str[i]);
      final remaining = str.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write(' ');
      }
    }
    return buffer.toString();
  }

  // Copy with updated count
  Zikr withIncrement(int increment) {
    return copyWith(
      currentCount: currentCount + increment,
      totalCount: totalCount + increment,
      updatedAt: DateTime.now(),
    );
  }

  Zikr withDecrement(int decrement) {
    final newCount = (currentCount - decrement).clamp(0, currentCount);
    return copyWith(
      currentCount: newCount,
      updatedAt: DateTime.now(),
    );
  }

  Zikr withNewTarget(int newTarget) {
    return copyWith(
      targetCount: newTarget,
      updatedAt: DateTime.now(),
    );
  }

  Zikr withManualCount(int newCount) {
    return copyWith(
      currentCount: newCount.clamp(0, newCount),
      updatedAt: DateTime.now(),
    );
  }

  Zikr resetCurrentCount() {
    return copyWith(
      currentCount: 0,
      updatedAt: DateTime.now(),
    );
  }

  Zikr addPracticeTime(int seconds) {
    return copyWith(
      practiceTimeSeconds: practiceTimeSeconds + seconds,
      updatedAt: DateTime.now(),
    );
  }
}

// ============================================
// SETTINGS MODEL
// ============================================
@freezed
@HiveType(typeId: 2, adapterName: 'AppSettingsAdapter')
class AppSettings with _$AppSettings {
  const AppSettings._();

  const factory AppSettings({
    @HiveField(0) @Default(ThemeMode.system) ThemeMode themeMode,
    @HiveField(1) @Default(true) bool hapticsEnabled,
    @HiveField(10) @Default(HapticIntensity.medium) HapticIntensity hapticIntensity,
    @HiveField(2) @Default(true) bool soundEnabled,
    @HiveField(3) @Default(5) int warningThresholdPercent,
    @HiveField(4) @Default(NumberFormatType.spaceSeparated) NumberFormatType numberFormat,
    @HiveField(5) @Default('ru') String languageCode,
    @HiveField(6) @Default(false) bool volumeKeysEnabled,
    @HiveField(7) @Default(true) bool keepScreenOn,
    @HiveField(8) @Default(1.0) double textScale,
    @HiveField(9) @Default(false) bool reduceAnimations,
  }) = _AppSettings;

  factory AppSettings.fromJson(Map<String, dynamic> json) => _$AppSettingsFromJson(json);
}

@HiveType(typeId: 3)
enum ThemeMode {
  @HiveField(0)
  light,
  @HiveField(1)
  dark,
  @HiveField(2)
  system,
}

@HiveType(typeId: 4)
enum HapticIntensity {
  @HiveField(0)
  light,
  @HiveField(1)
  medium,
  @HiveField(2)
  heavy,
}

@HiveType(typeId: 5)
enum NumberFormatType {
  @HiveField(0)
  spaceSeparated,
  @HiveField(1)
  commaSeparated,
  @HiveField(2)
  plain,
}

// ============================================
// DAILY STATISTICS
// ============================================
@freezed
@HiveType(typeId: 6, adapterName: 'DailyStatAdapter')
class DailyStat with _$DailyStat {
  const DailyStat._();

  const factory DailyStat({
    @HiveField(0) required String dateKey, // YYYY-MM-DD
    @HiveField(1) required Map<String, int> zikrCounts, // zikrId -> count
    @HiveField(2) required Map<String, int> zikrTimeSeconds, // zikrId -> seconds
    @HiveField(3) required Map<String, int> completedTargets, // zikrId -> count
    @HiveField(4) @Default(0) int totalCount,
    @HiveField(5) @Default(0) int totalTimeSeconds,
    @HiveField(6) @Default(0) int totalCompletedTargets,
  }) = _DailyStat;

  factory DailyStat.fromJson(Map<String, dynamic> json) => _$DailyStatFromJson(json);

  bool get hasActivity => totalCount > 0;

  int get activeZikrsCount => zikrCounts.keys.where((k) => zikrCounts[k]! > 0).length;
}

// ============================================
// SESSION MODEL (for undo functionality)
// ============================================
@freezed
@HiveType(typeId: 7, adapterName: 'ZikrSessionAdapter')
class ZikrSession with _$ZikrSession {
  const ZikrSession._();

  const factory ZikrSession({
    @HiveField(0) required String id,
    @HiveField(1) required String zikrId,
    @HiveField(2) required int previousCount,
    @HiveField(3) required int newCount,
    @HiveField(4) required DateTime timestamp,
    @HiveField(5) required SessionType type,
  }) = _ZikrSession;

  factory ZikrSession.fromJson(Map<String, dynamic> json) => _$ZikrSessionFromJson(json);
}

@HiveType(typeId: 8)
enum SessionType {
  @HiveField(0)
  increment,
  @HiveField(1)
  decrement,
  @HiveField(2)
  reset,
  @HiveField(3)
  manualSet,
  @HiveField(4)
  newRound,
}

// ============================================
// BACKUP MODEL
// ============================================
@freezed
@HiveType(typeId: 9, adapterName: 'BackupDataAdapter')
class BackupData with _$BackupData {
  const BackupData._();

  const factory BackupData({
    @HiveField(0) required String version,
    @HiveField(1) required DateTime exportedAt,
    @HiveField(2) required List<Zikr> zikrs,
    @HiveField(3) required AppSettings settings,
    @HiveField(4) required List<DailyStat> dailyStats,
    @HiveField(5) required List<ZikrSession> recentSessions,
  }) = _BackupData;

  factory BackupData.fromJson(Map<String, dynamic> json) => _$BackupDataFromJson(json);
}

// ============================================
// PREDEFINED SUNNAH AZKAR DATA
// ============================================
class SunnahAzkar {
  static const List<Map<String, dynamic>> azkar = [
    {
      'id': 'subhanallah',
      'name': 'Субханаллах',
      'arabic': 'سُبْحَانَ اللَّهِ',
      'transliteration': 'Subhanallah',
      'translation': 'Пречистен Аллах',
      'target': 33,
      'color': 0xFF006D5B,
      'source': 'Сахих аль-Бухари, 6406; Сахих Муслим, 597',
    },
    {
      'id': 'alhamdulillah',
      'name': 'Альхамдулиллях',
      'arabic': 'الْحَمْدُ لِلَّهِ',
      'transliteration': 'Alhamdulillah',
      'translation': 'Хвала Аллаху',
      'target': 33,
      'color': 0xFF007B7F,
      'source': 'Сахих аль-Бухари, 6406; Сахих Муслим, 597',
    },
    {
      'id': 'allahu_akbar',
      'name': 'Аллаху Акбар',
      'arabic': 'اللَّهُ أَكْبَرُ',
      'transliteration': 'Allahu Akbar',
      'translation': 'Аллах Величайший',
      'target': 34,
      'color': 0xFF00838F,
      'source': 'Сахих аль-Бухари, 6406; Сахих Муслим, 597',
    },
    {
      'id': 'la_ilaha_illa_allah',
      'name': 'Ля иляха илляллах',
      'arabic': 'لَا إِلَهَ إِلَّا اللَّهُ',
      'transliteration': 'La ilaha illa Allah',
      'translation': 'Нет божества, кроме Аллаха',
      'target': 100,
      'color': 0xFF006064,
      'source': 'Сахих аль-Бухари, 6406; Сахих Муслим, 597',
    },
    {
      'id': 'astaghfirullah',
      'name': 'Астагфируллах',
      'arabic': 'أَسْتَغْفِرُ اللَّهَ',
      'transliteration': 'Astaghfirullah',
      'translation': 'Прошу прощения у Аллаха',
      'target': 100,
      'color': 0xFF004D40,
      'source': 'Сахих аль-Бухари, 6307; Сахих Муслим, 2702',
    },
    {
      'id': 'subhanallah_wa_bihamdihi',
      'name': 'Субханаллах ва бихамдихи',
      'arabic': 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
      'transliteration': 'Subhanallah wa bihamdihi',
      'translation': 'Пречистен Аллах и Ему хвала',
      'target': 100,
      'color': 0xFF00796B,
      'source': 'Сахих аль-Бухари, 6405; Сахих Муслим, 2691',
    },
    {
      'id': 'subhanallah_azim',
      'name': 'Субханаллах аль-Азим',
      'arabic': 'سُبْحَانَ اللَّهِ الْعَظِيمِ',
      'transliteration': 'Subhanallah al-Azim',
      'translation': 'Пречистен Аллах Великий',
      'target': 100,
      'color': 0xFF00695C,
      'source': 'Сахих аль-Бухари, 6405; Сахих Муслим, 2691',
    },
    {
      'id': 'la_haula_wala_quwwata',
      'name': 'Ля хауля ва ля куввата илля биллах',
      'arabic': 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
      'transliteration': 'La hawla wa la quwwata illa billah',
      'translation': 'Нет силы и нет мощи, кроме Аллаха',
      'target': 100,
      'color': 0xFF004D40,
      'source': 'Сахих аль-Бухари, 7386; Сахих Муслим, 2704',
    },
  ];

  static List<Zikr> toZikrList() {
    return azkar.map((data) => Zikr(
      id: data['id'] as String,
      name: data['name'] as String,
      arabicText: data['arabic'] as String,
      transliteration: data['transliteration'] as String,
      translation: data['translation'] as String,
      targetCount: data['target'] as int,
      currentCount: 0,
      totalCount: 0,
      practiceTimeSeconds: 0,
      colorValue: data['color'] as int,
      category: ZikrCategory.sunnahAzkar,
      source: data['source'] as String,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      warningThreshold: null,
      autoResetOnTarget: false,
    )).toList();
  }
}