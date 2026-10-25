import 'package:core/core.dart';
import 'package:firebase/firebase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/testimonial/data/mapper/testimonial_mapper.dart';
import 'package:portrai/src/feature/testimonial/data/repository/remote_testimonial_repository_impl.dart';
import 'package:portrai/src/feature/testimonial/domain/_domain.dart';

import '../../../../../mock/feature/testimonial/domain/repository/mock_testimonial_repository.dart';
import '../../../../../mock/feature/testimonial/test_data/testimonial_test_data.dart';
import '../../../../../mock/utility/fake_error_reporter.dart';
import '../../../../../mock/utility/mock_fb_firestore_controller.dart';
import '../../../../../mock/utility/mock_log_reporter.dart';

void main() {
  const localeCode = 'en';
  final appLocale = AppLocale(localeCode);
  final mapper = TestimonialMapper(appLocale: appLocale);
  final testimonials = [
    createTestimonialEntity(),
    createTestimonialEntity(
      id: 'jane-doe',
      name: 'Jane Doe',
      position: 'Product Manager',
      company: 'Globex',
      testimonial: 'Rai is a reliable partner for complex product work.',
      date: '2024',
      profileImage: 'https://example.com/jane.png',
      companyLogo: 'https://example.com/globex.png',
      linkedinProfile: 'https://linkedin.com/in/jane-doe',
      projectContext: 'Admin Console',
    ),
  ];
  final firestoreDocument = {'testimonials': createTestimonialListJson()};

  group('RemoteTestimonialRepositoryImpl', () {
    late MockFbFirestoreController firestoreController;
    late MockTestimonialRepository cacheDelegateRepository;
    late MockLogReporter logReporter;
    late FakeErrorReporter errorReporter;
    late RemoteTestimonialRepositoryImpl repository;

    setUp(() {
      firestoreController = MockFbFirestoreController();
      cacheDelegateRepository = MockTestimonialRepository();
      logReporter = MockLogReporter();
      errorReporter = FakeErrorReporter();
      repository = RemoteTestimonialRepositoryImpl(
        firestoreController,
        appLocale,
        cacheDelegateRepository,
        mapper,
        logReporter,
        errorReporter,
      );
    });

    test(
      'should return cached testimonials when the cache already has data',
      () async {
        cacheDelegateRepository.stubGetTestimonials(testimonials);

        final result = await repository.getTestimonials();

        expect(result, testimonials);
        verify(() => cacheDelegateRepository.getTestimonials()).called(1);
        verifyNever(
          () => firestoreController.getDocumentFromCollection(any(), any()),
        );
      },
    );

    test(
      'should load testimonials from remote and cache them when the cache is empty',
      () async {
        cacheDelegateRepository.stubGetTestimonialsThrows(
          const TestimonialNotFoundException(),
        );
        firestoreController.stubGetDocumentFromCollection(firestoreDocument);
        cacheDelegateRepository.stubCacheTestimonials(testimonials);

        final result = await repository.getTestimonials();

        expect(result, testimonials);
        verify(
          () => firestoreController.getDocumentFromCollection(
            'testimonials',
            localeCode,
          ),
        ).called(1);
        verify(
          () => cacheDelegateRepository.cacheTestimonials(testimonials),
        ).called(1);
      },
    );

    test(
      'should return a single testimonial from remote when it is not cached',
      () async {
        final testimonial = testimonials.first;
        cacheDelegateRepository.stubGetTestimonialThrows(
          id: testimonial.id,
          error: const TestimonialNotFoundException(),
        );
        firestoreController.stubGetDocumentFromCollection(firestoreDocument);
        cacheDelegateRepository.stubCacheTestimonials(testimonials);

        final result = await repository.getTestimonial(testimonial.id);

        expect(result, testimonial);
        verify(
          () => logReporter.debug(
            'Testimonial ${testimonial.id} not found in cache, loading from remote',
            tag: 'RemoteTestimonialRepositoryImpl',
          ),
        ).called(1);
      },
    );

    test(
      'should log the cache error and still load testimonials from remote when the cache throws a cache exception',
      () async {
        cacheDelegateRepository.stubGetTestimonialsThrows(
          const TestimonialCacheException(),
        );
        firestoreController.stubGetDocumentFromCollection(firestoreDocument);
        cacheDelegateRepository.stubCacheTestimonials(testimonials);

        final result = await repository.getTestimonials();

        expect(result, testimonials);
        verify(
          () => logReporter.error(
            'Cache error while getting testimonials, loading from remote instead.',
            tag: 'RemoteTestimonialRepositoryImpl',
          ),
        ).called(1);
      },
    );

    test(
      'should report the error and continue when caching testimonials loaded from remote fails',
      () async {
        cacheDelegateRepository.stubGetTestimonialsThrows(
          const TestimonialNotFoundException(),
        );
        firestoreController.stubGetDocumentFromCollection(firestoreDocument);
        cacheDelegateRepository.stubCacheTestimonialsThrows(
          testimonials: testimonials,
          error: const TestimonialCacheException(cause: 'cache write failed'),
        );

        final result = await repository.getTestimonials();

        expect(result, testimonials);
        final reportedError = errorReporter.reportedErrors.single;
        expect(reportedError.exception, isA<TestimonialCacheException>());
        expect(reportedError.tag, 'RemoteTestimonialRepositoryImpl');
      },
    );

    test(
      'should throw an unauthorized exception when Firestore denies access',
      () {
        cacheDelegateRepository.stubGetTestimonialsThrows(
          const TestimonialNotFoundException(),
        );
        firestoreController.stubGetDocumentFromCollectionThrows(
          FirestorePermissionDeniedException(
            'read testimonials',
            StateError('forbidden'),
            StackTrace.empty,
          ),
        );

        expect(
          repository.getTestimonials,
          throwsA(isA<TestimonialUnauthorizedException>()),
        );
      },
    );

    test(
      'should throw a parsing exception when the remote payload is invalid',
      () {
        cacheDelegateRepository.stubGetTestimonialsThrows(
          const TestimonialNotFoundException(),
        );
        firestoreController.stubGetDocumentFromCollection({
          'testimonials': [
            {'name': 'broken'},
          ],
        });

        expect(
          repository.getTestimonials(),
          throwsA(isA<TestimonialParsingException>()),
        );
      },
    );

    test(
      'should replace the cached testimonials with the remote ones when refreshed',
      () async {
        firestoreController.stubGetDocumentFromCollection(firestoreDocument);
        cacheDelegateRepository
          ..stubRefreshTestimonials()
          ..stubCacheTestimonials(testimonials);

        await repository.refreshTestimonials();

        verifyInOrder([
          () => cacheDelegateRepository.refreshTestimonials(),
          () => cacheDelegateRepository.cacheTestimonials(testimonials),
        ]);
      },
    );

    test(
      'should keep the cached testimonials when loading the remote ones fails',
      () async {
        firestoreController.stubGetDocumentFromCollection(null);

        await expectLater(
          repository.refreshTestimonials,
          throwsA(isA<TestimonialNotFoundException>()),
        );
        verifyNever(() => cacheDelegateRepository.refreshTestimonials());
      },
    );
  });
}
