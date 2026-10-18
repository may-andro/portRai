import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/cv_export/domain/_domain.dart';
import 'package:portrai/src/feature/profile/domain/entity/language_entity.dart';

void main() {
  group('CvLanguageCode', () {
    test('should return the same code when the name is localized', () {
      expect(CvLanguageCode.of('English'), 'EN');
      expect(CvLanguageCode.of('Engels'), 'EN');
      expect(CvLanguageCode.of('Inglés'), 'EN');
    });

    test('should return the name when the language is unknown', () {
      expect(CvLanguageCode.of('Klingon'), 'Klingon');
    });

    group('ofLanguage', () {
      test('should use the ISO code when the data has one', () {
        const language = LanguageEntity(
          language: 'Anything',
          proficiency: 'Fluent',
          code: 'sv',
        );

        expect(CvLanguageCode.ofLanguage(language), 'SV');
      });

      test('should fall back to the name when there is no ISO code', () {
        const language = LanguageEntity(
          language: 'Dutch',
          proficiency: 'Fluent',
        );

        expect(CvLanguageCode.ofLanguage(language), 'NL');
      });
    });
  });
}
