import 'package:flutter/widgets.dart';

import '../domain/models/localized_text.dart';
import '../l10n/app_localizations.dart';

extension ContextL10n on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  String get localeName => Localizations.localeOf(this).toString();

  String localized(LocalizedText text) => text.resolve(Localizations.localeOf(this).languageCode);
}
