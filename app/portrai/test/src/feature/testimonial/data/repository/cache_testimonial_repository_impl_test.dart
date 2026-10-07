import 'package:cache/cache.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/testimonial/data/mapper/testimonial_mapper.dart';
import 'package:portrai/src/feature/testimonial/data/model/testimonial_model.dart';
import 'package:portrai/src/feature/testimonial/data/repository/cache_testimonial_repository_impl.dart';
import 'package:portrai/src/feature/testimonial/domain/_domain.dart';

import '../../../../../mock/feature/testimonial/data/cache/mock_testimonial_cache.dart';
import '../../../../../mock/feature/testimonial/test_data/testimonial_test_data.dart';

void main() {
  const localeCode = 'en';
  final appLocale = AppLocale(localeCode);
  final mapper = TestimonialMapper(appLocale: appLocale);
  final testimonial = createTestimonialEntity();
  final model = createTestimonialModel();

  group('CacheTestimonialRepositoryImpl', () {
    late MockTestimonialCache testimonialCache;
    late CacheTestimonialRepositoryImpl repository;

    setUpAll(() {
      registerFallbackValue(model);
    });

    setUp(() {
      testimonialCache = MockTestimonialCache();
      repository = CacheTestimonialRepositoryImpl(
        testimonialCache,
        mapper,
        appLocale,
      );
    });

    test(
      'should return mapped testimonials when cached records exist',
      () async {
        testimonialCache.stubQuery(
          conditions: {'locale': localeCode},
          result: [model],
        );

        final result = await repository.getTestimonials();

        expect(result, [testimonial]);
      },
    );

    test(
      'should throw a not found exception when the cache has no testimonials',
      () {
        testimonialCache.stubQuery(
          conditions: {'locale': localeCode},
          result: [],
        );

        expect(
          repository.getTestimonials,
          throwsA(isA<TestimonialNotFoundException>()),
        );
      },
    );

    test(
      'should return the cached testimonial when it exists for the locale',
      () async {
        testimonialCache.stubGet(
          conditions: {'id': testimonial.id, 'locale': localeCode},
          result: model,
        );

        final result = await repository.getTestimonial(testimonial.id);

        expect(result, testimonial);
      },
    );

    test(
      'should throw a not found exception when the testimonial ID is empty',
      () {
        expect(
          () => repository.getTestimonial('   '),
          throwsA(isA<TestimonialNotFoundException>()),
        );
      },
    );

    test(
      'should throw a not found exception when the cached testimonial is missing',
      () {
        testimonialCache.stubGet(
          conditions: {'id': testimonial.id, 'locale': localeCode},
          result: null,
        );

        expect(
          () => repository.getTestimonial(testimonial.id),
          throwsA(isA<TestimonialNotFoundException>()),
        );
      },
    );

    test('should cache the mapped testimonial when caching succeeds', () async {
      testimonialCache.stubPut();

      await repository.cacheTestimonial(testimonial);

      final captured =
          verify(() => testimonialCache.put(captureAny())).captured.single
              as TestimonialModel;
      expect(captured.toJson(), model.toJson());
    });

    test(
      'should throw a cache exception when the database is unavailable while caching',
      () {
        testimonialCache.stubPutThrows(
          DBNotInitialisedException(cause: Exception('db init failed')),
        );

        expect(
          () => repository.cacheTestimonial(testimonial),
          throwsA(isA<TestimonialCacheException>()),
        );
      },
    );

    test(
      'should throw a cache exception when the database is unavailable while reading the testimonial list',
      () {
        testimonialCache.stubQueryThrows(
          conditions: {'locale': localeCode},
          error: DBNotInitialisedException(cause: Exception('db init failed')),
        );

        expect(
          repository.getTestimonials,
          throwsA(isA<TestimonialCacheException>()),
        );
      },
    );
  });
}
