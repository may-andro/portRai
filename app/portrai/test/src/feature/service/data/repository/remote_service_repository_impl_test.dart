import 'package:core/core.dart';
import 'package:firebase/firebase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/service/data/mapper/service_mapper.dart';
import 'package:portrai/src/feature/service/data/repository/remote_service_repository_impl.dart';
import 'package:portrai/src/feature/service/domain/_domain.dart';

import '../../../../../mock/feature/service/domain/repository/mock_service_repository.dart';
import '../../../../../mock/utility/mock_fb_firestore_controller.dart';
import '../../../../../mock/utility/mock_log_reporter.dart';

void main() {
  const service = ServiceEntity(
    image: 'service.png',
    title: 'App Development',
    description: 'Beautiful apps',
    detail: 'Detailed service description',
  );

  group('RemoteServiceRepositoryImpl', () {
    late MockFbFirestoreController firestoreController;
    late MockServiceRepository cacheRepository;
    late MockLogReporter logReporter;
    late RemoteServiceRepositoryImpl repository;

    setUp(() {
      firestoreController = MockFbFirestoreController();
      cacheRepository = MockServiceRepository();
      logReporter = MockLogReporter();
      repository = RemoteServiceRepositoryImpl(
        firestoreController,
        AppLocale('en'),
        cacheRepository,
        ServiceMapper(appLocale: AppLocale('en')),
        logReporter,
      );
      when(
        () => logReporter.error(any(), tag: any(named: 'tag')),
      ).thenReturn(null);
    });

    test(
      'should return cached services when the cache already has data',
      () async {
        cacheRepository.stubGetServices(const [service]);

        expect(await repository.getServices(), const [service]);
        verify(() => cacheRepository.getServices()).called(1);
        verifyNever(
          () => firestoreController.getDocumentFromCollection(any(), any()),
        );
      },
    );

    test(
      'should load services from Firestore and cache them when the cache is empty',
      () async {
        cacheRepository.stubGetServicesThrows(const ServiceNotFoundException());
        cacheRepository.stubCacheService(service);
        firestoreController.stubGetDocumentFromCollection({
          'services': [
            {
              'title': service.title,
              'description': service.description,
              'image': service.image,
              'detail': service.detail,
            },
          ],
        });

        expect(await repository.getServices(), const [service]);
        verify(
          () => firestoreController.getDocumentFromCollection('services', 'en'),
        ).called(1);
        verify(() => cacheRepository.cacheService(service)).called(1);
      },
    );

    test(
      'should log the cache error and still load services from Firestore when reading the cache fails',
      () async {
        cacheRepository.stubGetServicesThrows(const ServiceCacheException());
        cacheRepository.stubCacheService(service);
        firestoreController.stubGetDocumentFromCollection({
          'services': [
            {
              'title': service.title,
              'description': service.description,
              'image': service.image,
              'detail': service.detail,
            },
          ],
        });

        await repository.getServices();

        verify(
          () => logReporter.error(
            'Cache error while getting services, loading from remote instead.',
            tag: 'RemoteServiceRepositoryImpl',
          ),
        ).called(1);
      },
    );

    test('should throw not found when the Firestore document is missing', () {
      cacheRepository.stubGetServicesThrows(const ServiceNotFoundException());
      firestoreController.stubGetDocumentFromCollectionThrows(
        FirestoreDocumentNotFoundException(
          'services/en',
          Exception('missing'),
          StackTrace.current,
        ),
      );

      expect(
        () => repository.getServices(),
        throwsA(isA<ServiceNotFoundException>()),
      );
    });

    test('should throw unauthorized when Firestore rejects access', () {
      cacheRepository.stubGetServicesThrows(const ServiceNotFoundException());
      firestoreController.stubGetDocumentFromCollectionThrows(
        FirestorePermissionDeniedException(
          'get-services',
          Exception('denied'),
          StackTrace.current,
        ),
      );

      expect(
        () => repository.getServices(),
        throwsA(isA<ServiceUnauthorizedException>()),
      );
    });

    test('should throw network when Firestore times out', () {
      cacheRepository.stubGetServicesThrows(const ServiceNotFoundException());
      firestoreController.stubGetDocumentFromCollectionThrows(
        FirestoreTimeoutException(
          'get-services',
          Exception('timeout'),
          StackTrace.current,
        ),
      );

      expect(
        () => repository.getServices(),
        throwsA(isA<ServiceNetworkException>()),
      );
    });

    test('should throw parsing when Firestore returns invalid data', () {
      cacheRepository.stubGetServicesThrows(const ServiceNotFoundException());
      firestoreController.stubGetDocumentFromCollection({
        'services': 'invalid',
      });

      expect(
        () => repository.getServices(),
        throwsA(isA<ServiceParsingException>()),
      );
    });

    test(
      'should continue returning services when caching the loaded Firestore data fails',
      () async {
        cacheRepository.stubGetServicesThrows(const ServiceNotFoundException());
        cacheRepository.stubCacheServiceThrows(
          service,
          const ServiceCacheException(),
        );
        firestoreController.stubGetDocumentFromCollection({
          'services': [
            {
              'title': service.title,
              'description': service.description,
              'image': service.image,
              'detail': service.detail,
            },
          ],
        });

        expect(await repository.getServices(), const [service]);
        verify(
          () => logReporter.error(
            'Failed to cache services from remote, continuing without caching.',
            tag: 'RemoteServiceRepositoryImpl',
          ),
        ).called(1);
      },
    );
  });
}
