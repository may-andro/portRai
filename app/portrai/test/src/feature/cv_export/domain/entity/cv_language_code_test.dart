import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/cv_export/domain/_domain.dart';
import 'package:portrai/src/feature/profile/domain/entity/language_entity.dart';

void main() {
  group('CvLanguageCode', () {
    test('should return the upper-cased ISO code when the data has one', () {
      const language = LanguageEntity(
        language: 'Anything',
        proficiency: 'Fluent',
        code: 'sv',
      );

      expect(CvLanguageCode.ofLanguage(language), 'SV');
    });

    test('should return null when the data has no code', () {
      const language = LanguageEntity(language: 'Dutch', proficiency: 'Fluent');

      expect(CvLanguageCode.ofLanguage(language), isNull);
    });
  });
}
