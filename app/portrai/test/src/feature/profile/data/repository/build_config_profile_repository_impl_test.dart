import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/profile/data/repository/build_config_profile_repository_impl.dart';

import '../../../../../mock/feature/profile/domain/repository/mock_profile_repository.dart';
import '../../../../../mock/feature/profile/test_data/profile_test_data.dart';

void main() {
  final profile = createProfileEntity();

  for (final environment in BuildEnvironment.values) {
    group('BuildConfigProfileRepositoryImpl ($environment)', () {
      late MockProfileRepository remote;
      late MockProfileRepository asset;
      late BuildConfigProfileRepositoryImpl repository;
      late MockProfileRepository selected;
      late MockProfileRepository unselected;

      setUp(() {
        remote = MockProfileRepository();
        asset = MockProfileRepository();
        repository = BuildConfigProfileRepositoryImpl(
          BuildConfig(buildEnvironment: environment),
          remote,
          asset,
        );
        selected = environment == BuildEnvironment.prod ? remote : asset;
        unselected = environment == BuildEnvironment.prod ? asset : remote;
      });

      test(
        'should delegate profile reads to the selected source when requested',
        () async {
          selected.stubGetProfile(profile);

          expect(await repository.getProfile(), profile);
          verify(() => selected.getProfile()).called(1);
          verifyNever(() => unselected.getProfile());
        },
      );

      test(
        'should delegate cache writes to the selected source when requested',
        () async {
          selected.stubCacheProfile(profile);

          await repository.cacheProfile(profile);

          verify(() => selected.cacheProfile(profile)).called(1);
          verifyNever(() => unselected.cacheProfile(profile));
        },
      );
    });
  }
}
