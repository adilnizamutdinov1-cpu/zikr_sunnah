// Модели данных приложения «Зикр по Сунне».
// Чистые immutable-классы с toMap/fromMap — без codegen, надёжно на вебе и мобильных.

import 'package:flutter/material.dart';

/// Категория зикра.
enum ZikrCategory {
  sunnah, // из готового списка по Сунне
  personal, // создан пользователем
}

/// Режим темы.
enum AppThemeMode { light, dark, system }

/// Сила вибрации.
enum HapticIntensity { light, medium, heavy }

/// Формат отображения чисел.
enum NumberFormatType { space, comma, plain }

// ──────────────────────────────────────────────────────────────────────────
// Zikr — один зикр (счётчик)
// ──────────────────────────────────────────────────────────────────────────
class Zikr {
  final String id;
  final String name;
  final String arabicText;
  final String transliteration;
  final String translation;
  final String? source; // проверяемый источник (хадис и т.п.)
  final int targetCount; // цель (33, 100, 1000, ...)
  final int currentCount; // счёт в текущем круге
  final int totalCount; // накопленный общий счёт
  final int step; // на сколько увеличивать за нажатие (НОВОЕ)
  final int practiceTimeSeconds; // общее время практики
  final int colorValue; // цвет акцента
  final ZikrCategory category;
  final int? warningThreshold; // кастомный порог предупреждения (% до цели), иначе null = по настройке
  final DateTime createdAt;
  final DateTime updatedAt;

  const Zikr({
    required this.id,
    required this.name,
    required this.arabicText,
    required this.transliteration,
    required this.translation,
    this.source,
    required this.targetCount,
    required this.currentCount,
    required this.totalCount,
    required this.step,
    required this.practiceTimeSeconds,
    required this.colorValue,
    required this.category,
    this.warningThreshold,
    required this.createdAt,
    required this.updatedAt,
  });

  Color get color => Color(colorValue);

  /// Прогресс к цели 0..1 (защищён от деления на 0 и переполнения цели).
  double get progress {
    if (targetCount <= 0) return 0;
    if (currentCount >= targetCount) return 1;
    return currentCount / targetCount;
  }

  bool get isTargetReached => currentCount >= targetCount;

  int get remainingToTarget =>
      currentCount >= targetCount ? 0 : targetCount - currentCount;

  /// Показывать ли предупреждение «почти у цели» по заданному проценту.
  bool showWarning(int warningPercent) {
    final w = warningThreshold ?? warningPercent;
    if (targetCount <= 0 || w <= 0 || w >= 100) return false;
    final threshold = targetCount - (targetCount * w / 100).floor();
    return currentCount >= threshold && !isTargetReached;
  }

  /// Копирование с изменением полей.
  Zikr copyWith({
    String? id,
    String? name,
    String? arabicText,
    String? transliteration,
    String? translation,
    Object? source = _sentinel,
    int? targetCount,
    int? currentCount,
    int? totalCount,
    int? step,
    int? practiceTimeSeconds,
    int? colorValue,
    ZikrCategory? category,
    Object? warningThreshold = _sentinel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Zikr(
      id: id ?? this.id,
      name: name ?? this.name,
      arabicText: arabicText ?? this.arabicText,
      transliteration: transliteration ?? this.transliteration,
      translation: translation ?? this.translation,
      source: identical(source, _sentinel) ? this.source : source as String?,
      targetCount: targetCount ?? this.targetCount,
      currentCount: currentCount ?? this.currentCount,
      totalCount: totalCount ?? this.totalCount,
      step: step ?? this.step,
      practiceTimeSeconds: practiceTimeSeconds ?? this.practiceTimeSeconds,
      colorValue: colorValue ?? this.colorValue,
      category: category ?? this.category,
      warningThreshold: identical(warningThreshold, _sentinel)
          ? this.warningThreshold
          : warningThreshold as int?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Увеличить счёт: currentCount += by, totalCount += by. Не обнуляется при цели.
  Zikr withIncrement(int by) => copyWith(
        currentCount: currentCount + by,
        totalCount: totalCount + by,
      );

  Zikr withManualCount(int count) => copyWith(
        currentCount: count.clamp(0, 1 << 30),
      );

  Zikr withNewTarget(int target) => copyWith(
        targetCount: target < 1 ? 1 : target,
        currentCount: 0,
      );

  Zikr withStep(int newStep) => copyWith(step: newStep < 1 ? 1 : newStep);

  Zikr resetCurrentCount() => copyWith(currentCount: 0);

  Zikr addPracticeTime(int seconds) =>
      copyWith(practiceTimeSeconds: practiceTimeSeconds + seconds);

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'arabicText': arabicText,
        'transliteration': transliteration,
        'translation': translation,
        'source': source,
        'targetCount': targetCount,
        'currentCount': currentCount,
        'totalCount': totalCount,
        'step': step,
        'practiceTimeSeconds': practiceTimeSeconds,
        'colorValue': colorValue,
        'category': category.name,
        'warningThreshold': warningThreshold,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Zikr.fromMap(Map<dynamic, dynamic> map) => Zikr(
        id: map['id'] as String,
        name: map['name'] as String? ?? '',
        arabicText: map['arabicText'] as String? ?? '',
        transliteration: map['transliteration'] as String? ?? '',
        translation: map['translation'] as String? ?? '',
        source: map['source'] as String?,
        targetCount: (map['targetCount'] as num?)?.toInt() ?? 100,
        currentCount: (map['currentCount'] as num?)?.toInt() ?? 0,
        totalCount: (map['totalCount'] as num?)?.toInt() ?? 0,
        step: (map['step'] as num?)?.toInt() ?? 1,
        practiceTimeSeconds: (map['practiceTimeSeconds'] as num?)?.toInt() ?? 0,
        colorValue: (map['colorValue'] as num?)?.toInt() ?? 0xFFD4A843,
        category: ZikrCategory.values.byName(
          map['category'] as String? ?? 'personal',
        ),
        warningThreshold: (map['warningThreshold'] as num?)?.toInt(),
        createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
            DateTime.now(),
        updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ??
            DateTime.now(),
      );

  static const _sentinel = Object();
}

// ──────────────────────────────────────────────────────────────────────────
// AppSettings — настройки приложения
// ──────────────────────────────────────────────────────────────────────────
class AppSettings {
  final AppThemeMode themeMode;
  final bool hapticsEnabled;
  final HapticIntensity hapticIntensity;
  final bool soundEnabled;
  final int warningThresholdPercent; // 0..100, 0 = выкл
  final NumberFormatType numberFormat;
  final String languageCode;
  final bool countAnimation; // «Анимация счёта» — НОВОЕ
  final double textScale;

  const AppSettings({
    this.themeMode = AppThemeMode.system,
    this.hapticsEnabled = true,
    this.hapticIntensity = HapticIntensity.light,
    this.soundEnabled = false,
    this.warningThresholdPercent = 5,
    this.numberFormat = NumberFormatType.space,
    this.languageCode = 'ru',
    this.countAnimation = true,
    this.textScale = 1.0,
  });

  AppSettings copyWith({
    AppThemeMode? themeMode,
    bool? hapticsEnabled,
    HapticIntensity? hapticIntensity,
    bool? soundEnabled,
    int? warningThresholdPercent,
    NumberFormatType? numberFormat,
    String? languageCode,
    bool? countAnimation,
    double? textScale,
  }) =>
      AppSettings(
        themeMode: themeMode ?? this.themeMode,
        hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
        hapticIntensity: hapticIntensity ?? this.hapticIntensity,
        soundEnabled: soundEnabled ?? this.soundEnabled,
        warningThresholdPercent:
            warningThresholdPercent ?? this.warningThresholdPercent,
        numberFormat: numberFormat ?? this.numberFormat,
        languageCode: languageCode ?? this.languageCode,
        countAnimation: countAnimation ?? this.countAnimation,
        textScale: textScale ?? this.textScale,
      );

  Map<String, dynamic> toMap() => {
        'themeMode': themeMode.name,
        'hapticsEnabled': hapticsEnabled,
        'hapticIntensity': hapticIntensity.name,
        'soundEnabled': soundEnabled,
        'warningThresholdPercent': warningThresholdPercent,
        'numberFormat': numberFormat.name,
        'languageCode': languageCode,
        'countAnimation': countAnimation,
        'textScale': textScale,
      };

  factory AppSettings.fromMap(Map<dynamic, dynamic> map) => AppSettings(
        themeMode: AppThemeMode.values
            .byName(map['themeMode'] as String? ?? 'system'),
        hapticsEnabled: map['hapticsEnabled'] as bool? ?? true,
        hapticIntensity: HapticIntensity.values
            .byName(map['hapticIntensity'] as String? ?? 'light'),
        soundEnabled: map['soundEnabled'] as bool? ?? false,
        warningThresholdPercent:
            (map['warningThresholdPercent'] as num?)?.toInt() ?? 5,
        numberFormat: NumberFormatType.values
            .byName(map['numberFormat'] as String? ?? 'space'),
        languageCode: map['languageCode'] as String? ?? 'ru',
        countAnimation: map['countAnimation'] as bool? ?? true,
        textScale: (map['textScale'] as num?)?.toDouble() ?? 1.0,
      );
}

// ──────────────────────────────────────────────────────────────────────────
// DailyStat — активность за один день
// ──────────────────────────────────────────────────────────────────────────
class DailyStat {
  /// Ключ даты 'yyyy-MM-dd'.
  final String dateKey;
  final int totalCount;
  final int practiceSeconds;
  final DateTime updatedAt;

  const DailyStat({
    required this.dateKey,
    required this.totalCount,
    required this.practiceSeconds,
    required this.updatedAt,
  });

  DateTime get date => DateTime.tryParse(dateKey) ?? DateTime.now();

  DailyStat copyWith({
    String? dateKey,
    int? totalCount,
    int? practiceSeconds,
    DateTime? updatedAt,
  }) =>
      DailyStat(
        dateKey: dateKey ?? this.dateKey,
        totalCount: totalCount ?? this.totalCount,
        practiceSeconds: practiceSeconds ?? this.practiceSeconds,
        updatedAt: updatedAt ?? DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'dateKey': dateKey,
        'totalCount': totalCount,
        'practiceSeconds': practiceSeconds,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory DailyStat.fromMap(Map<dynamic, dynamic> map) => DailyStat(
        dateKey: map['dateKey'] as String,
        totalCount: (map['totalCount'] as num?)?.toInt() ?? 0,
        practiceSeconds: (map['practiceSeconds'] as num?)?.toInt() ?? 0,
        updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ??
            DateTime.now(),
      );
}

// ──────────────────────────────────────────────────────────────────────────
// ZikrSession — для функции «Отменить сброс»
// ──────────────────────────────────────────────────────────────────────────
class ZikrSession {
  final String id;
  final String zikrId;
  final int previousCount;
  final DateTime createdAt;

  const ZikrSession({
    required this.id,
    required this.zikrId,
    required this.previousCount,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'zikrId': zikrId,
        'previousCount': previousCount,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ZikrSession.fromMap(Map<dynamic, dynamic> map) => ZikrSession(
        id: map['id'] as String,
        zikrId: map['zikrId'] as String,
        previousCount: (map['previousCount'] as num?)?.toInt() ?? 0,
        createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );
}

// ──────────────────────────────────────────────────────────────────────────
// BackupData — структура файла резервной копии
// ──────────────────────────────────────────────────────────────────────────
class BackupData {
  final String version;
  final DateTime exportedAt;
  final List<Zikr> zikrs;
  final AppSettings settings;
  final List<DailyStat> dailyStats;
  final String activeZikrId;

  const BackupData({
    required this.version,
    required this.exportedAt,
    required this.zikrs,
    required this.settings,
    required this.dailyStats,
    required this.activeZikrId,
  });

  Map<String, dynamic> toMap() => {
        'version': version,
        'exportedAt': exportedAt.toIso8601String(),
        'activeZikrId': activeZikrId,
        'zikrs': zikrs.map((z) => z.toMap()).toList(),
        'settings': settings.toMap(),
        'dailyStats': dailyStats.map((d) => d.toMap()).toList(),
      };

  factory BackupData.fromMap(Map<dynamic, dynamic> map) => BackupData(
        version: map['version'] as String? ?? '1.0.0',
        exportedAt:
            DateTime.tryParse(map['exportedAt'] as String? ?? '') ??
                DateTime.now(),
        activeZikrId: map['activeZikrId'] as String? ?? '',
        zikrs: ((map['zikrs'] as List?) ?? const [])
            .map((e) => Zikr.fromMap(e as Map<dynamic, dynamic>))
            .toList(),
        settings: AppSettings.fromMap(
          (map['settings'] as Map<dynamic, dynamic>?) ?? const {},
        ),
        dailyStats: ((map['dailyStats'] as List?) ?? const [])
            .map((e) => DailyStat.fromMap(e as Map<dynamic, dynamic>))
            .toList(),
      );
}

// ──────────────────────────────────────────────────────────────────────────
// SunnahAzkar — готовые азкары с проверяемыми источниками.
// ВАЖНО: здесь приведены только широко известные формулы. Конкретные
// рекомендации по числу повторений оставлены пользователю (по умолчанию 33/100),
// чтобы не утверждать ничего без надёжного источника. Поле source помечает
// происхождение текста для возможности проверки.
// ──────────────────────────────────────────────────────────────────────────
class SunnahAzkar {
  static List<Zikr> seed() {
    final now = DateTime.now();
    const cat = ZikrCategory.sunnah;
    return [
      Zikr(
        id: 'sunnah_subhanallah',
        name: 'СубханаЛлах',
        arabicText: 'سُبْحَانَ ٱللَّٰه',
        transliteration: 'СубханаЛлах',
        translation: 'Свят Аллах, далёк от любых недостатков',
        source: 'Общеизвестная формула зикра; см. Сахих аль-Бухари, Сахих Муслим',
        targetCount: 33,
        currentCount: 0,
        totalCount: 0,
        step: 1,
        practiceTimeSeconds: 0,
        colorValue: 0xFFD4A843,
        category: cat,
        createdAt: now,
        updatedAt: now,
      ),
      Zikr(
        id: 'sunnah_alhamdulillah',
        name: 'АльхамдулиЛлях',
        arabicText: 'ٱلْحَمْدُ لِلَّٰه',
        transliteration: 'АльхамдулиЛлях',
        translation: 'Вся хвала Аллаху',
        source: 'Общеизвестная формула зикра; см. Сахих аль-Бухари, Сахих Муслим',
        targetCount: 33,
        currentCount: 0,
        totalCount: 0,
        step: 1,
        practiceTimeSeconds: 0,
        colorValue: 0xFF7AA38C,
        category: cat,
        createdAt: now,
        updatedAt: now,
      ),
      Zikr(
        id: 'sunnah_allahuakbar',
        name: 'Аллаху Акбар',
        arabicText: 'ٱللَّٰهُ أَكْبَر',
        transliteration: 'Аллаху Акбар',
        translation: 'Аллах превелик',
        source: 'Общеизвестная формула зикра; см. Сахих аль-Бухари, Сахих Муслим',
        targetCount: 33,
        currentCount: 0,
        totalCount: 0,
        step: 1,
        practiceTimeSeconds: 0,
        colorValue: 0xFFB07A4A,
        category: cat,
        createdAt: now,
        updatedAt: now,
      ),
      Zikr(
        id: 'sunnah_astaghfirullah',
        name: 'АстагфируЛлах',
        arabicText: 'أَسْتَغْفِرُ ٱللَّٰه',
        transliteration: 'АстагфируЛлах',
        translation: 'Прошу прощения у Аллаха',
        source: 'Формула истигфара; см. Сахих аль-Бухари (книга «Ад-Даават»)',
        targetCount: 100,
        currentCount: 0,
        totalCount: 0,
        step: 1,
        practiceTimeSeconds: 0,
        colorValue: 0xFF6E8FAE,
        category: cat,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}
