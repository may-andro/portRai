import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/app_config/app_config.dart';
import 'package:use_case/use_case.dart';

class _FakeAppConfig extends AppConfig {
  const _FakeAppConfig();
}

void main() {
  group('GetMinimumRequiredAppVersionUseCase', () {
    test('should return Right(minimumRequiredAppVersion) when AppConfig is a '
        'PortraiAppConfigEntity', () async {
      const appConfig = PortraiAppConfigEntity(
        minimumRequiredAppVersion: '1.2.3',
      );
      final useCase = GetMinimumRequiredAppVersionUseCase(appConfig);

      final result = await useCase();

      expect(result.isRight, true);
      expect(result.right, '1.2.3');
    });

    test('should return Left(NoFailure) when AppConfig is not a '
        'PortraiAppConfigEntity', () async {
      final useCase = GetMinimumRequiredAppVersionUseCase(
        const _FakeAppConfig(),
      );

      final result = await useCase();

      expect(result.isLeft, true);
      expect(result.left, isA<NoFailure>());
    });
  });
}
