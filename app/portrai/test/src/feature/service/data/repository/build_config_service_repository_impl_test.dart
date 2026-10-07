import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/service/data/repository/build_config_service_repository_impl.dart';
import 'package:portrai/src/feature/service/domain/_domain.dart';

import '../../../../../mock/feature/service/domain/repository/mock_service_repository.dart';

void main() {
  const service = ServiceEntity(
    image: 'service.png',
    title: 'App Development',
    description: 'Beautiful apps',
    detail: 'Detailed service description',
  );

  for (final environment in BuildEnvironment.values) {
    group('BuildConfigServiceRepositoryImpl ($environment)', () {
      late MockServiceRepository remote;
      late MockServiceRepository asset;
      late BuildConfigServiceRepositoryImpl repository;
      late MockServiceRepository selected;
      late MockServiceRepository unselected;

      setUp(() {
        remote = MockServiceRepository();
        asset = MockServiceRepository();
        repository = BuildConfigServiceRepositoryImpl(
          BuildConfig(buildEnvironment: environment),
          remote,
          asset,
        );
        selected = environment == BuildEnvironment.prod ? remote : asset;
        unselected = environment == BuildEnvironment.prod ? asset : remote;
      });

      test(
        'should delegate list reads to the selected source when requested',
        () async {
          selected.stubGetServices(const [service]);

          expect(await repository.getServices(), const [service]);
          verify(() => selected.getServices()).called(1);
          verifyNever(() => unselected.getServices());
        },
      );

      test(
        'should delegate cache writes to the selected source when requested',
        () async {
          selected.stubCacheService(service);

          await repository.cacheService(service);

          verify(() => selected.cacheService(service)).called(1);
          verifyNever(() => unselected.cacheService(service));
        },
      );
    });
  }
}
