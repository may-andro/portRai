import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/expertise/data/repository/build_config_expertise_repository_impl.dart';
import 'package:portrai/src/feature/expertise/domain/_domain.dart';

import '../../../../../mock/feature/expertise/domain/repository/mock_expertise_repository.dart';

void main() {
  const expertise = ExpertiseEntity(
    image: 'https://example.com/flutter.png',
    title: 'Flutter Development',
    skills: ['Flutter SDK', 'State Management'],
  );

  for (final environment in BuildEnvironment.values) {
    group('BuildConfigExpertiseRepositoryImpl ($environment)', () {
      late MockExpertiseRepository remote;
      late MockExpertiseRepository asset;
      late BuildConfigExpertiseRepositoryImpl repository;
      late MockExpertiseRepository selected;
      late MockExpertiseRepository unselected;

      setUp(() {
        remote = MockExpertiseRepository();
        asset = MockExpertiseRepository();
        repository = BuildConfigExpertiseRepositoryImpl(
          BuildConfig(buildEnvironment: environment),
          remote,
          asset,
        );
        selected = environment == BuildEnvironment.prod ? remote : asset;
        unselected = environment == BuildEnvironment.prod ? asset : remote;
      });

      test(
        'should delegate expertise reads to the selected source when requested',
        () async {
          selected.stubGetAllExpertise([expertise]);

          expect(await repository.getAllExpertise(), [expertise]);
          verify(() => selected.getAllExpertise()).called(1);
          verifyNever(() => unselected.getAllExpertise());
        },
      );

      test(
        'should delegate cache writes to the selected source when requested',
        () async {
          selected.stubCacheExpertise(expertise);

          await repository.cacheExpertise(expertise);

          verify(() => selected.cacheExpertise(expertise)).called(1);
          verifyNever(() => unselected.cacheExpertise(expertise));
        },
      );
    });
  }
}
