import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/cv_export/domain/_domain.dart';

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
  });
}
