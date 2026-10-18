import 'package:portrai/src/feature/profile/domain/entity/language_entity.dart';

/// Short codes for the language names found in the (localized) portfolio data.
class CvLanguageCode {
  const CvLanguageCode._();

  static const Map<String, String> _codesByName = {
    'english': 'EN',
    'engels': 'EN',
    'inglés': 'EN',
    'spanish': 'ES',
    'spaans': 'ES',
    'español': 'ES',
    'dutch': 'NL',
    'nederlands': 'NL',
    'neerlandés': 'NL',
    'swedish': 'SV',
    'zweeds': 'SV',
    'sueco': 'SV',
    'german': 'DE',
    'duits': 'DE',
    'alemán': 'DE',
    'french': 'FR',
    'frans': 'FR',
    'francés': 'FR',
    'italian': 'IT',
    'italiaans': 'IT',
    'italiano': 'IT',
    'hindi': 'HI',
  };

  /// The code of [language]: its ISO code when the data has one, else the
  /// code looked up from the localized name.
  static String ofLanguage(LanguageEntity language) {
    final code = language.code?.trim();
    if (code != null && code.isNotEmpty) return code.toUpperCase();
    return of(language.language);
  }

  /// The code of [languageName], or the name itself when it is unknown.
  static String of(String languageName) {
    return _codesByName[languageName.trim().toLowerCase()] ??
        languageName.trim();
  }
}
