import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'app_localizations.dart';

export 'app_localizations.dart';

extension L10nContext on BuildContext {
  /// Localized strings (English / Indonesian, following the device language).
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Localized strings for code without a BuildContext (error messages thrown by
/// repositories, helpers). Follows Intl.defaultLocale, which app.dart sets
/// from the device language.
AppLocalizations get currentL10n {
  final lang = Intl.getCurrentLocale().split(RegExp('[-_]')).first;
  return lookupAppLocalizations(Locale(lang == 'id' ? 'id' : 'en'));
}
