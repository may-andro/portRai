import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/app_config/app_config.dart';

void main() {
  group('PortraiAppConfigEntity', () {
    test('fromJson should create an instance from a valid map', () {
      final appConfig = PortraiAppConfigEntity.fromJson({
        'minimumRequiredAppVersion': '1.2.3',
      });

      expect(appConfig.minimumRequiredAppVersion, '1.2.3');
    });

    test('toJson should return a map representation', () {
      const appConfig = PortraiAppConfigEntity(
        minimumRequiredAppVersion: '1.2.3',
      );

      expect(appConfig.toJson(), {'minimumRequiredAppVersion': '1.2.3'});
    });

    test('toJson/fromJson round trip should produce an equal instance', () {
      const appConfig = PortraiAppConfigEntity(
        minimumRequiredAppVersion: '4.5.6',
      );

      final result = PortraiAppConfigEntity.fromJson(appConfig.toJson());

      expect(result, appConfig);
    });

    test('should be equal when minimumRequiredAppVersion matches', () {
      const first = PortraiAppConfigEntity(minimumRequiredAppVersion: '1.0.0');
      const second = PortraiAppConfigEntity(minimumRequiredAppVersion: '1.0.0');

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('should not be equal when minimumRequiredAppVersion differs', () {
      const first = PortraiAppConfigEntity(minimumRequiredAppVersion: '1.0.0');
      const second = PortraiAppConfigEntity(minimumRequiredAppVersion: '2.0.0');

      expect(first, isNot(second));
    });

    test('toString should include the minimumRequiredAppVersion', () {
      const appConfig = PortraiAppConfigEntity(
        minimumRequiredAppVersion: '1.0.0',
      );

      expect(
        appConfig.toString(),
        'PortraiAppConfigEntity(minimumRequiredAppVersion: 1.0.0)',
      );
    });
  });
}
