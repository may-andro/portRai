import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/app_config/app_config.dart';

void main() {
  group('PortraiAppConfig', () {
    test('fromJson should create an instance from a valid map', () {
      final appConfig = PortraiAppConfig.fromJson({
        'minimumRequiredAppVersion': '1.2.3',
      });

      expect(appConfig.minimumRequiredAppVersion, '1.2.3');
    });

    test('toJson should return a map representation', () {
      const appConfig = PortraiAppConfig(minimumRequiredAppVersion: '1.2.3');

      expect(appConfig.toJson(), {'minimumRequiredAppVersion': '1.2.3'});
    });

    test('toJson/fromJson round trip should produce an equal instance', () {
      const appConfig = PortraiAppConfig(minimumRequiredAppVersion: '4.5.6');

      final result = PortraiAppConfig.fromJson(appConfig.toJson());

      expect(result, appConfig);
    });

    test('should be equal when minimumRequiredAppVersion matches', () {
      const first = PortraiAppConfig(minimumRequiredAppVersion: '1.0.0');
      const second = PortraiAppConfig(minimumRequiredAppVersion: '1.0.0');

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('should not be equal when minimumRequiredAppVersion differs', () {
      const first = PortraiAppConfig(minimumRequiredAppVersion: '1.0.0');
      const second = PortraiAppConfig(minimumRequiredAppVersion: '2.0.0');

      expect(first, isNot(second));
    });

    test('toString should include the minimumRequiredAppVersion', () {
      const appConfig = PortraiAppConfig(minimumRequiredAppVersion: '1.0.0');

      expect(
        appConfig.toString(),
        'PortraiAppConfig(minimumRequiredAppVersion: 1.0.0)',
      );
    });
  });
}
