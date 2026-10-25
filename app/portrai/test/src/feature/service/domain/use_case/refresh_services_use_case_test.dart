import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/service/domain/_domain.dart';

import '../../../../../mock/feature/service/domain/repository/mock_service_repository.dart';

void main() {
  group('RefreshServicesUseCase', () {
    late MockServiceRepository repository;
    late RefreshServicesUseCase useCase;

    setUp(() {
      repository = MockServiceRepository();
      useCase = RefreshServicesUseCase(repository);
    });

    test('should succeed when the repository refreshes the services', () async {
      repository.stubRefreshServices();

      final result = await useCase();

      expect(result.isRight, isTrue);
    });

    final failures = <(Object, Type)>[
      (const ServiceNetworkException(), RefreshServicesNetworkFailure),
      (const ServiceUnauthorizedException(), RefreshServicesNetworkFailure),
      (const ServiceNotFoundException(), RefreshServicesDataFailure),
      (const ServiceParsingException(), RefreshServicesDataFailure),
      (const ServiceCacheException(), RefreshServicesDataFailure),
      (Exception('unexpected'), RefreshServicesUnknownFailure),
    ];

    for (final (error, failureType) in failures) {
      test(
        'should return $failureType when the repository throws $error',
        () async {
          repository.stubRefreshServicesThrows(error);

          final result = await useCase();

          expect(result.left.runtimeType, failureType);
          expect(result.left.cause, same(error));
        },
      );
    }
  });
}
