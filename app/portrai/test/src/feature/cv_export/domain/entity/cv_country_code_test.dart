import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/cv_export/domain/_domain.dart';

void main() {
  group('CvCountryCode', () {
    test('should return the same code when the name is localized', () {
      expect(CvCountryCode.of('Germany'), 'DE');
      expect(CvCountryCode.of('Alemania'), 'DE');
      expect(CvCountryCode.of('Duitsland'), 'DE');
    });

    test('should return the name when the country is unknown', () {
      expect(CvCountryCode.of('Atlantis'), 'Atlantis');
    });
  });
}
