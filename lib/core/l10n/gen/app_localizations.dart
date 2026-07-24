import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ru'),
    Locale('ar'),
    Locale('en'),
    Locale('uk'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ru, this message translates to:
  /// **'Зикр по Сунне'**
  String get appTitle;

  /// No description provided for @tapAnywhere.
  ///
  /// In ru, this message translates to:
  /// **'Нажмите в любом месте'**
  String get tapAnywhere;

  /// No description provided for @goal.
  ///
  /// In ru, this message translates to:
  /// **'Цель'**
  String get goal;

  /// No description provided for @step.
  ///
  /// In ru, this message translates to:
  /// **'Шаг'**
  String get step;

  /// No description provided for @customStep.
  ///
  /// In ru, this message translates to:
  /// **'Свой шаг'**
  String get customStep;

  /// No description provided for @customGoal.
  ///
  /// In ru, this message translates to:
  /// **'Свой шаг'**
  String get customGoal;

  /// No description provided for @goalReached.
  ///
  /// In ru, this message translates to:
  /// **'Цель выполнена'**
  String get goalReached;

  /// No description provided for @goalReachedMessage.
  ///
  /// In ru, this message translates to:
  /// **'Поздравляем! Вы достигли цели. Счёт продолжается.'**
  String get goalReachedMessage;

  /// No description provided for @newRound.
  ///
  /// In ru, this message translates to:
  /// **'Новый круг'**
  String get newRound;

  /// No description provided for @continueTotal.
  ///
  /// In ru, this message translates to:
  /// **'Продолжить общий счёт'**
  String get continueTotal;

  /// No description provided for @outOf.
  ///
  /// In ru, this message translates to:
  /// **'из'**
  String get outOf;

  /// No description provided for @zikrs.
  ///
  /// In ru, this message translates to:
  /// **'Зикры'**
  String get zikrs;

  /// No description provided for @path.
  ///
  /// In ru, this message translates to:
  /// **'Путь'**
  String get path;

  /// No description provided for @settings.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get settings;

  /// No description provided for @sunnahAzkar.
  ///
  /// In ru, this message translates to:
  /// **'По Сунне'**
  String get sunnahAzkar;

  /// No description provided for @myZikrs.
  ///
  /// In ru, this message translates to:
  /// **'Мои зикры'**
  String get myZikrs;

  /// No description provided for @addZikr.
  ///
  /// In ru, this message translates to:
  /// **'Добавить зикр'**
  String get addZikr;

  /// No description provided for @editZikr.
  ///
  /// In ru, this message translates to:
  /// **'Редактировать'**
  String get editZikr;

  /// No description provided for @delete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get delete;

  /// No description provided for @duplicate.
  ///
  /// In ru, this message translates to:
  /// **'Дублировать'**
  String get duplicate;

  /// No description provided for @reset.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить счёт'**
  String get reset;

  /// No description provided for @resetConfirmTitle.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить счёт?'**
  String get resetConfirmTitle;

  /// No description provided for @resetConfirmMessage.
  ///
  /// In ru, this message translates to:
  /// **'Текущий счёт этого зикра будет обнулён. Общий счёт сохранится. Это действие можно отменить в течение 10 секунд.'**
  String get resetConfirmMessage;

  /// No description provided for @cancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get cancel;

  /// No description provided for @undo.
  ///
  /// In ru, this message translates to:
  /// **'Отменить'**
  String get undo;

  /// No description provided for @confirm.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердить'**
  String get confirm;

  /// No description provided for @name.
  ///
  /// In ru, this message translates to:
  /// **'Название'**
  String get name;

  /// No description provided for @arabicText.
  ///
  /// In ru, this message translates to:
  /// **'Арабский текст'**
  String get arabicText;

  /// No description provided for @transliteration.
  ///
  /// In ru, this message translates to:
  /// **'Транскрипция'**
  String get transliteration;

  /// No description provided for @translation.
  ///
  /// In ru, this message translates to:
  /// **'Перевод'**
  String get translation;

  /// No description provided for @source.
  ///
  /// In ru, this message translates to:
  /// **'Источник'**
  String get source;

  /// No description provided for @color.
  ///
  /// In ru, this message translates to:
  /// **'Цвет'**
  String get color;

  /// No description provided for @save.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get save;

  /// No description provided for @deleteZikrConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Удалить этот зикр? Счёт и статистика будут потеряны.'**
  String get deleteZikrConfirm;

  /// No description provided for @selectGoal.
  ///
  /// In ru, this message translates to:
  /// **'Выберите цель'**
  String get selectGoal;

  /// No description provided for @selectStep.
  ///
  /// In ru, this message translates to:
  /// **'Выберите шаг счёта'**
  String get selectStep;

  /// No description provided for @onePress.
  ///
  /// In ru, this message translates to:
  /// **'При одном нажатии'**
  String get onePress;

  /// No description provided for @customValue.
  ///
  /// In ru, this message translates to:
  /// **'Введите значение'**
  String get customValue;

  /// No description provided for @myJourney.
  ///
  /// In ru, this message translates to:
  /// **'Мой путь'**
  String get myJourney;

  /// No description provided for @streak.
  ///
  /// In ru, this message translates to:
  /// **'Серия'**
  String get streak;

  /// No description provided for @days.
  ///
  /// In ru, this message translates to:
  /// **'дней'**
  String get days;

  /// No description provided for @today.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get today;

  /// No description provided for @thisWeek.
  ///
  /// In ru, this message translates to:
  /// **'За неделю'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In ru, this message translates to:
  /// **'За месяц'**
  String get thisMonth;

  /// No description provided for @allTime.
  ///
  /// In ru, this message translates to:
  /// **'За всё время'**
  String get allTime;

  /// No description provided for @practiceTime.
  ///
  /// In ru, this message translates to:
  /// **'Время зикра'**
  String get practiceTime;

  /// No description provided for @completedGoals.
  ///
  /// In ru, this message translates to:
  /// **'Завершённые цели'**
  String get completedGoals;

  /// No description provided for @noActivity.
  ///
  /// In ru, this message translates to:
  /// **'Пока нет активности. Начните с одного нажатия.'**
  String get noActivity;

  /// No description provided for @appearance.
  ///
  /// In ru, this message translates to:
  /// **'Оформление'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In ru, this message translates to:
  /// **'Тема'**
  String get theme;

  /// No description provided for @themeLight.
  ///
  /// In ru, this message translates to:
  /// **'Светлая'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In ru, this message translates to:
  /// **'Тёмная'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In ru, this message translates to:
  /// **'Как в системе'**
  String get themeSystem;

  /// No description provided for @haptics.
  ///
  /// In ru, this message translates to:
  /// **'Вибрация'**
  String get haptics;

  /// No description provided for @hapticsEnabled.
  ///
  /// In ru, this message translates to:
  /// **'Включить вибрацию'**
  String get hapticsEnabled;

  /// No description provided for @hapticIntensity.
  ///
  /// In ru, this message translates to:
  /// **'Сила вибрации'**
  String get hapticIntensity;

  /// No description provided for @hapticLight.
  ///
  /// In ru, this message translates to:
  /// **'Лёгкая'**
  String get hapticLight;

  /// No description provided for @hapticMedium.
  ///
  /// In ru, this message translates to:
  /// **'Средняя'**
  String get hapticMedium;

  /// No description provided for @hapticHeavy.
  ///
  /// In ru, this message translates to:
  /// **'Сильная'**
  String get hapticHeavy;

  /// No description provided for @sound.
  ///
  /// In ru, this message translates to:
  /// **'Звук'**
  String get sound;

  /// No description provided for @soundEnabled.
  ///
  /// In ru, this message translates to:
  /// **'Включить звук'**
  String get soundEnabled;

  /// No description provided for @warning.
  ///
  /// In ru, this message translates to:
  /// **'Предупреждение'**
  String get warning;

  /// No description provided for @warningBeforeGoal.
  ///
  /// In ru, this message translates to:
  /// **'Вибрация перед достижением цели'**
  String get warningBeforeGoal;

  /// No description provided for @numberFormat.
  ///
  /// In ru, this message translates to:
  /// **'Формат чисел'**
  String get numberFormat;

  /// No description provided for @countAnimation.
  ///
  /// In ru, this message translates to:
  /// **'Анимация счёта'**
  String get countAnimation;

  /// No description provided for @countAnimationDesc.
  ///
  /// In ru, this message translates to:
  /// **'Спокойная анимация при каждом нажатии'**
  String get countAnimationDesc;

  /// No description provided for @language.
  ///
  /// In ru, this message translates to:
  /// **'Язык'**
  String get language;

  /// No description provided for @backup.
  ///
  /// In ru, this message translates to:
  /// **'Резервная копия'**
  String get backup;

  /// No description provided for @exportBackup.
  ///
  /// In ru, this message translates to:
  /// **'Экспортировать копию'**
  String get exportBackup;

  /// No description provided for @importBackup.
  ///
  /// In ru, this message translates to:
  /// **'Импортировать копию'**
  String get importBackup;

  /// No description provided for @exportSuccess.
  ///
  /// In ru, this message translates to:
  /// **'Резервная копия сохранена'**
  String get exportSuccess;

  /// No description provided for @importSuccess.
  ///
  /// In ru, this message translates to:
  /// **'Данные восстановлены'**
  String get importSuccess;

  /// No description provided for @importError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось восстановить: неверный файл'**
  String get importError;

  /// No description provided for @about.
  ///
  /// In ru, this message translates to:
  /// **'О приложении'**
  String get about;

  /// No description provided for @offlineOnly.
  ///
  /// In ru, this message translates to:
  /// **'Полностью офлайн — без рекламы и интернета'**
  String get offlineOnly;

  /// No description provided for @version.
  ///
  /// In ru, this message translates to:
  /// **'Версия'**
  String get version;

  /// No description provided for @add.
  ///
  /// In ru, this message translates to:
  /// **'Добавить'**
  String get add;

  /// No description provided for @edit.
  ///
  /// In ru, this message translates to:
  /// **'Изменить'**
  String get edit;

  /// No description provided for @perDay.
  ///
  /// In ru, this message translates to:
  /// **'за день'**
  String get perDay;

  /// No description provided for @totalCount.
  ///
  /// In ru, this message translates to:
  /// **'Общий счёт'**
  String get totalCount;

  /// No description provided for @finishedGoals.
  ///
  /// In ru, this message translates to:
  /// **'Завершено целей'**
  String get finishedGoals;

  /// No description provided for @noZikrs.
  ///
  /// In ru, this message translates to:
  /// **'Зикров пока нет. Нажмите «+», чтобы создать.'**
  String get noZikrs;

  /// No description provided for @noZikrsSunnah.
  ///
  /// In ru, this message translates to:
  /// **'Готовые азкары скоро появятся.'**
  String get noZikrsSunnah;

  /// No description provided for @min.
  ///
  /// In ru, this message translates to:
  /// **'мин'**
  String get min;

  /// No description provided for @hour.
  ///
  /// In ru, this message translates to:
  /// **'ч'**
  String get hour;

  /// No description provided for @minutes.
  ///
  /// In ru, this message translates to:
  /// **'минуты'**
  String get minutes;

  /// No description provided for @seconds.
  ///
  /// In ru, this message translates to:
  /// **'сек'**
  String get seconds;

  /// No description provided for @percentLeft.
  ///
  /// In ru, this message translates to:
  /// **'осталось'**
  String get percentLeft;

  /// No description provided for @goalCompleteTitle.
  ///
  /// In ru, this message translates to:
  /// **'Цель выполнена!'**
  String get goalCompleteTitle;

  /// No description provided for @keepCounting.
  ///
  /// In ru, this message translates to:
  /// **'Счёт продолжается — Аллах примет ваши поминания.'**
  String get keepCounting;

  /// No description provided for @warningVibration.
  ///
  /// In ru, this message translates to:
  /// **'Почти у цели'**
  String get warningVibration;

  /// No description provided for @enterManually.
  ///
  /// In ru, this message translates to:
  /// **'Ввести вручную'**
  String get enterManually;

  /// No description provided for @minus.
  ///
  /// In ru, this message translates to:
  /// **'Уменьшить'**
  String get minus;

  /// No description provided for @plus10.
  ///
  /// In ru, this message translates to:
  /// **'+10'**
  String get plus10;

  /// No description provided for @plus100.
  ///
  /// In ru, this message translates to:
  /// **'+100'**
  String get plus100;

  /// No description provided for @plus1000.
  ///
  /// In ru, this message translates to:
  /// **'+1 000'**
  String get plus1000;

  /// No description provided for @enterExact.
  ///
  /// In ru, this message translates to:
  /// **'Введите точный счёт'**
  String get enterExact;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'ru', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'uk':
      return AppLocalizationsUk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
