import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/service/domain/_domain.dart';

import '../../../../../mock/feature/service/domain/repository/mock_service_repository.dart';

void main() {
  const service = ServiceEntity(
    image: 'service.png',
    title: 'App Development',
    description: 'Beautiful apps',
    detail: 'Detailed service description',
  );

  group('GetServicesUseCase', () {
    late MockServiceRepository repository;
    late GetServicesUseCase useCase;

    setUp(() {
      repository = MockServiceRepository();
      useCase = GetServicesUseCase(repository);
    });

    test('should return all services when the repository succeeds', () async {
      repository.stubGetServices(const [service]);

      final result = await useCase();

      expect(result.isRight, isTrue);
      expect(result.right, const [service]);
    });

    test(
      'should return a not found failure when the repository reports missing services',
      () async {
        repository.stubGetServicesThrows(const ServiceNotFoundException());

        final result = await useCase();

        expect(result.left, isA<ServicesNotFoundFailure>());
      },
    );

    test(
      'should return a network failure when the repository reports a network error',
      () async {
        repository.stubGetServicesThrows(const ServiceNetworkException());

        final result = await useCase();

        expect(result.left, isA<ServicesNetworkFailure>());
      },
    );

    test(
      'should return a data failure when the repository reports a parsing error',
      () async {
        repository.stubGetServicesThrows(const ServiceParsingException());

        final result = await useCase();

        expect(result.left, isA<ServicesDataFailure>());
      },
    );

    test(
      'should return an unauthorized failure when the repository rejects access',
      () async {
        repository.stubGetServicesThrows(const ServiceUnauthorizedException());

        final result = await useCase();

        expect(result.left, isA<ServicesUnauthorizedFailure>());
      },
    );

    test(
      'should return a data failure when the repository reports a cache error',
      () async {
        repository.stubGetServicesThrows(const ServiceCacheException());

        final result = await useCase();

        expect(result.left, isA<ServicesDataFailure>());
      },
    );

    test(
      'should return an unknown failure when the repository throws an unexpected error',
      () async {
        repository.stubGetServicesThrows(Exception('boom'));

        final result = await useCase();

        expect(result.left, isA<ServicesUnknownFailure>());
      },
    );
  });
}
