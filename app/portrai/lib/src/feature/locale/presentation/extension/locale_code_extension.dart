import 'package:portrai/l10n/generated/app_localizations.dart';

extension LocaleCodeExtension on String {
  String languageName(AppLocalizations localizations) {
    switch (this) {
      case 'en':
        return localizations.localeLanguageEnglish;
      case 'nl':
        return localizations.localeLanguageDutch;
      case 'es':
        return localizations.localeLanguageSpanish;
      default:
        return localizations.localeLanguageUnknown;
    }
  }
}
