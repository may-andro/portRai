import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/app_config/app_config.dart';
import 'package:portrai/src/feature/app_config/domain/use_case/initialize_app_config_use_case.dart';

import '../../../../../mock/feature/app_config/domain/repository/mock_app_config_repository.dart';

void main() {
  group('InitializeAppConfigUseCase', () {
    late MockAppConfigRepository appConfigRepository;
    late InitializeAppConfigUseCase useCase;

    setUp(() {
      appConfigRepository = MockAppConfigRepository();
      useCase = InitializeAppConfigUseCase(appConfigRepository);
    });

    test(
      'should return Right(PortraiAppConfigEntity) when the repository succeeds',
      () async {
        const appConfig = PortraiAppConfigEntity(
          minimumRequiredAppVersion: '1.0.0',
        );
        appConfigRepository.stubGetAppConfig(appConfig);

        final result = await useCase();

        expect(result.isRight, true);
        expect(result.right, appConfig);
      },
    );

    test('should return Left(InitializeAppConfigNetworkFailure) when the '
        'repository throws a network related error', () async {
      appConfigRepository.stubGetAppConfigThrows(Exception('network timeout'));

      final result = await useCase();

      expect(result.isLeft, true);
      expect(result.left, isA<InitializeAppConfigNetworkFailure>());
    });

    test('should return Left(InitializeAppConfigCacheFailure) when the '
        'repository throws a cache related error', () async {
      appConfigRepository.stubGetAppConfigThrows(Exception('cache miss'));

      final result = await useCase();

      expect(result.isLeft, true);
      expect(result.left, isA<InitializeAppConfigCacheFailure>());
    });

    test('should return Left(InitializeAppConfigUnknownFailure) when the '
        'repository throws an unrecognised error', () async {
      appConfigRepository.stubGetAppConfigThrows(Exception('boom'));

      final result = await useCase();

      expect(result.isLeft, true);
      expect(result.left, isA<InitializeAppConfigUnknownFailure>());
    });
  });
}
