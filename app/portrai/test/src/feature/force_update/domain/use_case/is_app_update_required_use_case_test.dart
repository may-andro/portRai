import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/force_update/domain/_domain.dart';

import '../../../../../mock/feature/app_config/domain/use_case/mock_get_minimum_required_app_version_use_case.dart';
import '../../../../../mock/feature/force_update/domain/repository/mock_app_version_repository.dart';

void main() {
  group('IsAppUpdateRequiredUseCase', () {
    late MockGetMinimumRequiredAppVersionUseCase
    getMinimumRequiredAppVersionUseCase;
    late MockAppVersionRepository appVersionRepository;
    late IsAppUpdateRequiredUseCase useCase;

    setUp(() {
      getMinimumRequiredAppVersionUseCase =
          MockGetMinimumRequiredAppVersionUseCase();
      appVersionRepository = MockAppVersionRepository();
      useCase = IsAppUpdateRequiredUseCase(
        getMinimumRequiredAppVersionUseCase,
        appVersionRepository,
      );
    });

    test(
      'should return Right(true) when current version is lower than minimum required version',
      () async {
        getMinimumRequiredAppVersionUseCase.stubCall('2.0.0');
        appVersionRepository.stubGetCurrentAppVersion('1.0.0');

        final result = await useCase();

        expect(result.isRight, true);
        expect(result.right, true);
      },
    );

    test(
      'should return Right(false) when current version is equal to minimum required version',
      () async {
        getMinimumRequiredAppVersionUseCase.stubCall('1.0.0');
        appVersionRepository.stubGetCurrentAppVersion('1.0.0');

        final result = await useCase();

        expect(result.isRight, true);
        expect(result.right, false);
      },
    );

    test(
      'should return Right(false) when current version is higher than minimum required version',
      () async {
        getMinimumRequiredAppVersionUseCase.stubCall('1.0.0');
        appVersionRepository.stubGetCurrentAppVersion('2.0.0');

        final result = await useCase();

        expect(result.isRight, true);
        expect(result.right, false);
      },
    );

    test(
      'should return Left(IsAppUpdateRequiredUnknownFailure) when repository throws',
      () async {
        getMinimumRequiredAppVersionUseCase.stubCall('1.0.0');
        appVersionRepository.stubGetCurrentAppVersionThrows(Exception('boom'));

        final result = await useCase();

        expect(result.isLeft, true);
        expect(result.left, isA<IsAppUpdateRequiredUnknownFailure>());
      },
    );
  });
}
