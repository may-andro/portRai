import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/app_config/app_config.dart';

class _FakeAppConfig extends AppConfig {
  const _FakeAppConfig();
}

void main() {
  group('GetMinimumRequiredAppVersionUseCase', () {
    test('should return the minimum required app version when AppConfig is a '
        'PortraiAppConfig', () {
      const appConfig = PortraiAppConfig(minimumRequiredAppVersion: '1.2.3');
      final useCase = GetMinimumRequiredAppVersionUseCase(appConfig);

      final result = useCase();

      expect(result, '1.2.3');
    });

    test(
      'should throw StateError when AppConfig is not a PortraiAppConfig',
      () {
        final useCase = GetMinimumRequiredAppVersionUseCase(
          const _FakeAppConfig(),
        );

        expect(useCase.call, throwsA(isA<StateError>()));
      },
    );
  });
}
