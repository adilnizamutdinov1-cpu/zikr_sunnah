# Зикр по Сунне

Красивое, спокойное и полностью офлайн приложение для ежедневного зикра (поминания Аллаха). Построено на Flutter с Material 3.

## Особенности

- **Полностью офлайн** — никаких рекламы, авторизации, интернета или аналитики
- **Сохранение после каждого нажатия** — данные сохраняются мгновенно через Hive
- **Готовые азкары по Сунне** — Субханаллах, Альхамдулиллях, Аллаху Акбар и другие с указанием источников
- **Свои зикры** — создание, редактирование, удаление личных зикров
- **Настраиваемые цели** — 33, 100, 1000 или собственное число
- **Вибрация и звук** — настраиваемые тактильные отклики при нажатиях, предупреждении и достижении цели
- **Прогресс-кольцо** — красивая анимированная визуализация прогресса
- **Свайп для смены зикра** — переключение между зикрами жестом влево/вправо
- **Календарь активности** — отметка дней практики, серии дней подряд
- **Статистика** — за день, неделю, месяц и всё время
- **Тёмная и светлая тема** — глубокий изумрудный фон, тёплый кремовый текст, золотистый акцент
- **Многоязычность** — русский, украинский, английский, арабский (RTL поддержка)
- **Резервное копирование** — экспорт/импорт JSON-файла с данными
- **Доступность** — крупный текст, высокая читаемость, поддержка пожилых людей

## Структура проекта

```
lib/
├── main.dart                          # Точка входа, инициализация, роутинг
├── core/
│   ├── models/
│   │   └── zikr_models.dart          # Freezed модели: Zikr, AppSettings, DailyStat, ZikrSession, BackupData
│   ├── storage/
│   │   ├── hive_adapters.dart        # Hive TypeAdapters для всех моделей
│   │   └── storage_repository_impl.dart # Репозиторий для работы с Hive
│   ├── theme/
│   │   └── app_theme.dart            # Material 3 темы (dark/light), IslamicPatternPainter
│   └── localization/
│       └── app_localizations.dart    # Поддерживаемые локали, делегаты
├── presentation/
│   ├── providers/
│   │   └── zikr_providers.dart       # Riverpod провайдеры для состояния
│   ├── screens/
│   │   ├── main/
│   │   │   └── main_screen.dart      # Главный экран: счётчик, кольцо прогресса, быстрые действия
│   │   ├── zikrs/
│   │   │   └── zikrs_screen.dart     # Список азкаров и своих зикров
│   │   ├── path/
│   │   │   └── path_screen.dart      # Календарь, статистика, серии дней
│   │   └── settings/
│   │       └── settings_screen.dart  # Все настройки приложения
│   └── widgets/
│       ├── common/
│       │   ├── common_widgets.dart   # Общие виджеты: EmptyState, LoadingState, SectionHeader
│       │   └── islamic_pattern_bg.dart # Фон с исламским геометрическим узором
│       ├── counter/
│       │   ├── counter_widgets.dart  # Кнопки увеличения, выбор цели
│       │   └── progress_ring.dart    # Анимированное кольцо прогресса
│       ├── zikrs/
│       │   └── zikr_widgets.dart     # Карточка зикра, диалог добавления/редактирования
│       └── path/
│           └── path_widgets.dart     # Виджеты статистики для экрана Путь
l10n/
├── app_ru.arb                        # Русский (полный)
├── app_uk.arb                        # Украинский (полный)
├── app_en.arb                        # Английский (полный)
├── app_ar.arb                        # Арабский (полный, RTL)
```

## Зависимости

| Пакет | Назначение |
|-------|------------|
| `flutter_riverpod`, `riverpod_annotation` | Управление состоянием |
| `hive`, `hive_flutter` | Локальная БД (NoSQL, быстрая, реактивная) |
| `freezed_annotation`, `json_annotation` | Immutable модели с code generation |
| `flutter_animate` | Декларативные анимации |
| `vibration` | Тактильная обратная связь (хаптика) |
| `table_calendar` | Календарь активности |
| `file_picker`, `share_plus` | Экспорт/импорт резервных копий |
| `intl` | Форматирование дат, чисел, локализация |
| `path_provider` | Путь к директории документов |

## Установка и запуск

### Требования
- Flutter SDK 3.19+
- Dart SDK 3.3+
- Android Studio / Xcode для эмуляторов/устройств

### Шаги

1. **Клонировать и перейти в папку**
```bash
cd zikr_sunnah
```

2. **Установить зависимости**
```bash
flutter pub get
```

3. **Сгенерировать код** (Freezed, JSON, Riverpod, Hive adapters)
```bash
dart run build_runner build --delete-conflicting-outputs
```

4. **Запустить на устройстве/эмуляторе**
```bash
flutter run
```

### Сборка релизных версий

**Android (APK)**
```bash
flutter build apk --release
```

**Android (App Bundle для Play Console)**
```bash
flutter build appbundle --release
```

**iOS**
```bash
flutter build ios --release
```

**Web (для Telegram Mini App / PWA)**
```bash
flutter build web --wasm --release
```

## Генерация кода

При изменении моделей (`zikr_models.dart`), провайдеров (`zikr_providers.dart`) или адаптеров — перезапустите:
```bash
dart run build_runner build --delete-conflicting-outputs
```

Для режима watch (автогенерация при сохранении):
```bash
dart run build_runner watch --delete-conflicting-outputs
```

## Архитектура

### Слои
1. **Models** — Immutable data classes (Freezed) + Hive adapters
2. **Storage** — Repository pattern, Hive boxes, синхронные/асинхронные операции
3. **Providers** — Riverpod (StateNotifier, AsyncNotifier, StreamProvider)
4. **UI** — ConsumerWidget/ConsumerStatefulWidget, Material 3, кастомные виджеты

### Поток данных
```
User Action (Tap/Swipe)
    → Provider (CounterNotifier)
    → Repository (HiveStorageRepository)
    → Hive Box ( 즉시 запись )
    → UI rebuild (Consumer listening to provider)
```

### Сохранность данных
- Каждое нажатие сохраняется в Hive синхронно (await box.put)
- При выходе/сворачивании данные уже на диске
- При запуске: init Hive → open boxes → load active zikr → build UI

## Настройка целей и предупреждений

- Цели: 33, 100, 1000, пользовательская
- Предупреждение: настраиваемый % до цели (1%, 3%, 5%, 10%, 15%)
- Вибрация: лёгкая / средняя / сильная
- Звук: вкл/выкл
- Автосброс при цели: вкл/выкл (по умолчанию выкл — счёт продолжается)

## Локализация

ARB файлы в `l10n/`. Добавление нового языка:
1. Скопировать `app_ru.arb` → `app_<code>.arb`
2. Перевести значения
3. Добавить локаль в `supportedLocales` в `app_localizations.dart`
4. Запустить `flutter gen-l10n` (автоматически при сборке)

## Темизация

- `AppColors` — палитры для dark/light
- `AppTextStyles` — типографика (Display, Headline, Title, Body, Label, Arabic)
- `AppTheme.darkTheme` / `lightTheme` — полные ThemeData с Material 3
- `IslamicPatternPainter` — кастомный CustomPainter для фона
- Переключение через `ThemeModeNotifier` (Riverpod)

## Резервное копирование

Экспорт создаёт JSON с полной структурой:
```json
{
  "version": "1.0.0",
  "exportedAt": "2025-07-24T15:30:00Z",
  "zikrs": [...],
  "settings": {...},
  "dailyStats": [...],
  "recentSessions": [...]
}
```

Импорт полностью заменяет локальные данные.

## Лицензия

MIT License — свободное использование, модификация и распространение.

## Благодарности

- Азкары взяты из-authentic hadith collections (Sahih al-Bukhari, Sahih Muslim)
- Исламский геометрический узор — упрощённый 8-лучевой паттерн
- Иконки — Material Symbols (Google Fonts)

---

**Сделано с заботой о практике зикра. Пусть Аллах примет ваши поминания.** 🤲