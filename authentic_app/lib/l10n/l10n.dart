import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

export 'app_localizations.dart';

extension L10nContext on BuildContext {
  /// Localized strings (English / Indonesian, following the device language).
  AppLocalizations get l10n => AppLocalizations.of(this);
}
