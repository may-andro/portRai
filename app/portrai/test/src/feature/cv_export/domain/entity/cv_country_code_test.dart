import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/cv_export/domain/_domain.dart';
import 'package:portrai/src/feature/project/domain/entity/project_market_entity.dart';

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

    group('ofMarket', () {
      ProjectMarketEntity market(String country, {String? appStore}) {
        return ProjectMarketEntity(
          country: country,
          latitude: 0,
          longitude: 0,
          appStore: appStore,
        );
      }

      test('should use the App Store storefront when the link has one', () {
        final code = CvCountryCode.ofMarket(
          market('Anything', appStore: 'https://apps.apple.com/de/app/x/id1'),
        );

        expect(code, 'DE');
      });

      test('should fall back to the country name when no App Store link', () {
        expect(CvCountryCode.ofMarket(market('Spain')), 'ES');
      });
    });
  });
}
