import 'package:portrai/src/feature/profile/domain/entity/language_entity.dart';

/// ISO language codes, read from the data so they do not depend on the
/// (localized) language name.
class CvLanguageCode {
  const CvLanguageCode._();

  /// The upper-cased ISO code of [language], or `null` when the data has none.
  static String? ofLanguage(LanguageEntity language) {
    final code = language.code?.trim();
    if (code == null || code.isEmpty) return null;
    return code.toUpperCase();
  }
}
