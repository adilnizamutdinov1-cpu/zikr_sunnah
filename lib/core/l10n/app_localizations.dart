// Расширение для доступа к локализации через BuildContext.
// Сгенерированный класс AppLocalizations пишется в lib/core/l10n/gen/.

import 'package:flutter/material.dart';

import 'gen/app_localizations.dart';

export 'gen/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
