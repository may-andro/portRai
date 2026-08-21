import 'package:flutter/material.dart';
import 'package:portrai/l10n/generated/app_localizations.dart';

extension AppLocalizationsExtension on AppLocalizations {}

extension BuildContextLocalizationsExtension on BuildContext {
  AppLocalizations get localizations => AppLocalizations.of(this);

  String get languageCode => localizations.localeName;
}
