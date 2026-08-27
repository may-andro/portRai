import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/force_update/domain/_domain.dart';

import '../../../../../mock/feature/force_update/domain/repository/mock_app_version_repository.dart';

void main() {
  group('GetAppStoreUrlUseCase', () {
    late MockAppVersionRepository appVersionRepository;
    late GetAppStoreUrlUseCase useCase;

    setUp(() {
      appVersionRepository = MockAppVersionRepository();
      useCase = GetAppStoreUrlUseCase(appVersionRepository);
    });

    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
    });

    test(
      'should return Right with Play Store url when platform is Android',
      () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        appVersionRepository.stubGetPackageName('com.example.portrai');

        final result = await useCase();

        expect(result.isRight, true);
        expect(
          result.right.toString(),
          'https://play.google.com/store/apps/details?id=com.example.portrai',
        );
      },
    );

    test(
      'should return Right with App Store url when platform is iOS',
      () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

        final result = await useCase();

        expect(result.isRight, true);
        expect(
          result.right.toString(),
          startsWith('https://apps.apple.com/app/id'),
        );
        verifyNever(() => appVersionRepository.getPackageName());
      },
    );

    test(
      'should return Left(GetAppStoreUrlUnknownFailure) when repository throws',
      () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        appVersionRepository.stubGetPackageNameThrows(Exception('boom'));

        final result = await useCase();

        expect(result.isLeft, true);
        expect(result.left, isA<GetAppStoreUrlUnknownFailure>());
      },
    );
  });
}
