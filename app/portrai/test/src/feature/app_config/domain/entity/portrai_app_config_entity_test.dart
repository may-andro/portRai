import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/app_config/app_config.dart';

void main() {
  group('PortraiAppConfigEntity', () {
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

    test('should not be equal when the AI settings differ', () {
      const first = PortraiAppConfigEntity(minimumRequiredAppVersion: '1.0.0');

      expect(
        first,
        isNot(
          const PortraiAppConfigEntity(
            minimumRequiredAppVersion: '1.0.0',
            aiAssistantModel: 'gemini-test',
          ),
        ),
      );
      expect(
        first,
        isNot(
          const PortraiAppConfigEntity(
            minimumRequiredAppVersion: '1.0.0',
            aiRateLimit: AiRateLimitAppConfig(maxRequestsPerDay: 1),
          ),
        ),
      );
    });

    test('toString should include the minimumRequiredAppVersion', () {
      const appConfig = PortraiAppConfigEntity(
        minimumRequiredAppVersion: '1.0.0',
      );

      expect(
        appConfig.toString(),
        'PortraiAppConfigEntity(minimumRequiredAppVersion: 1.0.0, '
        'aiImage: AiImageAppConfig(null, null), '
        'aiAssistantModel: null, '
        'aiRateLimit: AiRateLimitAppConfig(null, null))',
      );
    });
  });
}
