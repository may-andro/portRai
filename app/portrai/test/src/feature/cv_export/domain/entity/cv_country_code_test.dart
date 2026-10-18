import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/cv_export/domain/_domain.dart';
import 'package:portrai/src/feature/project/domain/entity/project_market_entity.dart';

void main() {
  group('CvCountryCode', () {
    ProjectMarketEntity market({String? appStore, String? playStore}) {
      return ProjectMarketEntity(
        country: 'Alemania',
        latitude: 0,
        longitude: 0,
        appStore: appStore,
        playStore: playStore,
      );
    }

    test('should use the App Store storefront when the link has one', () {
      final code = CvCountryCode.ofMarket(
        market(appStore: 'https://apps.apple.com/de/app/x/id1'),
      );

      expect(code, 'DE');
    });

    test('should use the Play Store gl parameter when no App Store link', () {
      final code = CvCountryCode.ofMarket(
        market(playStore: 'https://play.google.com/store/apps?id=x&gl=nl'),
      );

      expect(code, 'NL');
    });

    test('should return null when the links carry no country', () {
      expect(
        CvCountryCode.ofMarket(
          market(playStore: 'https://play.google.com/store/apps?id=x'),
        ),
        isNull,
      );
    });
  });
}
