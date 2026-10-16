import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/app_config/app_config.dart';
import 'package:portrai/src/feature/force_update/domain/_domain.dart';

import '../../../../../mock/feature/force_update/domain/repository/mock_app_version_repository.dart';

void main() {
  group('IsAppUpdateRequiredUseCase', () {
    late MockAppVersionRepository appVersionRepository;

    setUp(() => appVersionRepository = MockAppVersionRepository());

    IsAppUpdateRequiredUseCase buildUseCase(String minimumVersion) =>
        IsAppUpdateRequiredUseCase(
          PortraiAppConfigEntity(minimumRequiredAppVersion: minimumVersion),
          appVersionRepository,
        );

    test(
      'should return Right(true) when current version is lower than minimum required version',
      () async {
        appVersionRepository.stubGetCurrentAppVersion('1.0.0');

        final result = await buildUseCase('2.0.0')();

        expect(result.isRight, true);
        expect(result.right, true);
      },
    );

    test(
      'should return Right(false) when current version is equal to minimum required version',
      () async {
        appVersionRepository.stubGetCurrentAppVersion('1.0.0');

        final result = await buildUseCase('1.0.0')();

        expect(result.isRight, true);
        expect(result.right, false);
      },
    );

    test(
      'should return Right(false) when current version is higher than minimum required version',
      () async {
        appVersionRepository.stubGetCurrentAppVersion('2.0.0');

        final result = await buildUseCase('1.0.0')();

        expect(result.isRight, true);
        expect(result.right, false);
      },
    );

    test(
      'should return Left(IsAppUpdateRequiredUnknownFailure) when repository throws',
      () async {
        appVersionRepository.stubGetCurrentAppVersionThrows(Exception('boom'));

        final result = await buildUseCase('1.0.0')();

        expect(result.isLeft, true);
        expect(result.left, isA<IsAppUpdateRequiredUnknownFailure>());
      },
    );
  });
}
