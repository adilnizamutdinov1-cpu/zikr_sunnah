// Hive Adapters for all models
// Generated with: dart run build_runner build --delete-conflicting-outputs

import 'package:hive/hive.dart';
import 'zikr_models.dart';

// ============================================
// ZIKR ADAPTER
// ============================================
class ZikrAdapter extends TypeAdapter<Zikr> {
  @override
  final int typeId = 0;

  @override
  Zikr read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    
    return Zikr(
      id: fields[0] as String,
      name: fields[1] as String,
      arabicText: fields[2] as String,
      transliteration: fields[3] as String,
      translation: fields[4] as String,
      targetCount: fields[5] as int,
      currentCount: fields[6] as int,
      totalCount: fields[7] as int,
      practiceTimeSeconds: fields[8] as int,
      colorValue: fields[9] as int,
      category: fields[10] as ZikrCategory,
      source: fields[11] as String,
      createdAt: fields[12] as DateTime,
      updatedAt: fields[13] as DateTime,
      warningThreshold: fields[14] as int?,
      autoResetOnTarget: fields[15] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Zikr obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.name)
      ..writeByte(2)..write(obj.arabicText)
      ..writeByte(3)..write(obj.transliteration)
      ..writeByte(4)..write(obj.translation)
      ..writeByte(5)..write(obj.targetCount)
      ..writeByte(6)..write(obj.currentCount)
      ..writeByte(7)..write(obj.totalCount)
      ..writeByte(8)..write(obj.practiceTimeSeconds)
      ..writeByte(9)..write(obj.colorValue)
      ..writeByte(10)..write(obj.category)
      ..writeByte(11)..write(obj.source)
      ..writeByte(12)..write(obj.createdAt)
      ..writeByte(13)..write(obj.updatedAt)
      ..writeByte(14)..write(obj.warningThreshold)
      ..writeByte(15)..write(obj.autoResetOnTarget);
  }
}

// ============================================
// APP SETTINGS ADAPTER
// ============================================
class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 1;

  @override
  AppSettings read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    
    return AppSettings(
      themeMode: fields[0] as ThemeMode,
      locale: fields[1] as String,
      hapticsEnabled: fields[2] as bool,
      soundEnabled: fields[3] as bool,
      hapticIntensity: fields[4] as HapticIntensity,
      warningThresholdPercent: fields[5] as int,
      numberFormat: fields[6] as NumberFormatType,
      volumeKeysEnabled: fields[7] as bool,
      keepScreenOn: fields[8] as bool,
      showTransliteration: fields[9] as bool,
      showTranslation: fields[10] as bool,
      showProgressRing: fields[11] as bool,
      autoAdvanceToNextZikr: fields[12] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)..write(obj.themeMode)
      ..writeByte(1)..write(obj.locale)
      ..writeByte(2)..write(obj.hapticsEnabled)
      ..writeByte(3)..write(obj.soundEnabled)
      ..writeByte(4)..write(obj.hapticIntensity)
      ..writeByte(5)..write(obj.warningThresholdPercent)
      ..writeByte(6)..write(obj.numberFormat)
      ..writeByte(7)..write(obj.volumeKeysEnabled)
      ..writeByte(8)..write(obj.keepScreenOn)
      ..writeByte(9)..write(obj.showTransliteration)
      ..writeByte(10)..write(obj.showTranslation)
      ..writeByte(11)..write(obj.showProgressRing)
      ..writeByte(12)..write(obj.autoAdvanceToNextZikr);
  }
}

// ============================================
// DAILY STAT ADAPTER
// ============================================
class DailyStatAdapter extends TypeAdapter<DailyStat> {
  @override
  final int typeId = 2;

  @override
  DailyStat read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    
    return DailyStat(
      dateKey: fields[0] as String,
      zikrCounts: Map<String, int>.from(fields[1] as Map),
      zikrTimeSeconds: Map<String, int>.from(fields[2] as Map),
      completedTargets: Map<String, int>.from(fields[3] as Map),
      totalCount: fields[4] as int,
      totalTimeSeconds: fields[5] as int,
      totalCompletedTargets: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, DailyStat obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)..write(obj.dateKey)
      ..writeByte(1)..write(obj.zikrCounts)
      ..writeByte(2)..write(obj.zikrTimeSeconds)
      ..writeByte(3)..write(obj.completedTargets)
      ..writeByte(4)..write(obj.totalCount)
      ..writeByte(5)..write(obj.totalTimeSeconds)
      ..writeByte(6)..write(obj.totalCompletedTargets);
  }
}

// ============================================
// ZIKR SESSION ADAPTER
// ============================================
class ZikrSessionAdapter extends TypeAdapter<ZikrSession> {
  @override
  final int typeId = 3;

  @override
  ZikrSession read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    
    return ZikrSession(
      id: fields[0] as String,
      zikrId: fields[1] as String,
      type: fields[2] as SessionType,
      previousValue: fields[3] as int,
      newValue: fields[4] as int,
      timestamp: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ZikrSession obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.zikrId)
      ..writeByte(2)..write(obj.type)
      ..writeByte(3)..write(obj.previousValue)
      ..writeByte(4)..write(obj.newValue)
      ..writeByte(5)..write(obj.timestamp);
  }
}

// ============================================
// BACKUP DATA ADAPTER
// ============================================
class BackupDataAdapter extends TypeAdapter<BackupData> {
  @override
  final int typeId = 4;

  @override
  BackupData read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    
    return BackupData(
      version: fields[0] as String,
      exportedAt: fields[1] as DateTime,
      zikrs: List<Zikr>.from(fields[2] as List),
      settings: fields[3] as AppSettings,
      dailyStats: List<DailyStat>.from(fields[4] as List),
      recentSessions: List<ZikrSession>.from(fields[5] as List),
    );
  }

  @override
  void write(BinaryWriter writer, BackupData obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)..write(obj.version)
      ..writeByte(1)..write(obj.exportedAt)
      ..writeByte(2)..write(obj.zikrs)
      ..writeByte(3)..write(obj.settings)
      ..writeByte(4)..write(obj.dailyStats)
      ..writeByte(5)..write(obj.recentSessions);
  }
}

// ============================================
// ENUM ADAPTERS
// ============================================
class ZikrCategoryAdapter extends TypeAdapter<ZikrCategory> {
  @override
  final int typeId = 5;

  @override
  ZikrCategory read(BinaryReader reader) {
    return ZikrCategory.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, ZikrCategory obj) {
    writer.writeByte(obj.index);
  }
}

class ThemeModeAdapter extends TypeAdapter<ThemeMode> {
  @override
  final int typeId = 6;

  @override
  ThemeMode read(BinaryReader reader) {
    return ThemeMode.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, ThemeMode obj) {
    writer.writeByte(obj.index);
  }
}

class HapticIntensityAdapter extends TypeAdapter<HapticIntensity> {
  @override
  final int typeId = 7;

  @override
  HapticIntensity read(BinaryReader reader) {
    return HapticIntensity.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, HapticIntensity obj) {
    writer.writeByte(obj.index);
  }
}

class NumberFormatTypeAdapter extends TypeAdapter<NumberFormatType> {
  @override
  final int typeId = 8;

  @override
  NumberFormatType read(BinaryReader reader) {
    return NumberFormatType.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, NumberFormatType obj) {
    writer.writeByte(obj.index);
  }
}

class SessionTypeAdapter extends TypeAdapter<SessionType> {
  @override
  final int typeId = 9;

  @override
  SessionType read(BinaryReader reader) {
    return SessionType.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, SessionType obj) {
    writer.writeByte(obj.index);
  }
}