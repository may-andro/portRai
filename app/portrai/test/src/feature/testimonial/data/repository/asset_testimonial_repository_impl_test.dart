import 'dart:convert';
import 'package:core/core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/testimonial/data/mapper/testimonial_mapper.dart';
import 'package:portrai/src/feature/testimonial/data/repository/asset_testimonial_repository_impl.dart';
import 'package:portrai/src/feature/testimonial/domain/_domain.dart';

import '../../../../../mock/feature/testimonial/domain/repository/mock_testimonial_repository.dart';
import '../../../../../mock/feature/testimonial/test_data/testimonial_test_data.dart';
import '../../../../../mock/utility/mock_log_reporter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
  final assetsJson = jsonEncode(
    createTestimonialAssetJson(testimonials: createTestimonialListJson()),
  );

  ByteData assetResponse() =>
      ByteData.sublistView(Uint8List.fromList(utf8.encode(assetsJson)));

  group('AssetTestimonialRepositoryImpl', () {
    late MockTestimonialRepository cacheDelegateRepository;
    late MockLogReporter logReporter;
    late AssetTestimonialRepositoryImpl repository;

    setUp(() {
      cacheDelegateRepository = MockTestimonialRepository();
      logReporter = MockLogReporter();
      repository = AssetTestimonialRepositoryImpl(
        appLocale,
        cacheDelegateRepository,
        mapper,
        logReporter,
      );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', (message) async {
            final key = const StringCodec().decodeMessage(message);
            if (key == 'assets/dashboard/testimonials.json') {
              return assetResponse();
            }
            return null;
          });
    });

    tearDown(() {
      rootBundle.evict('assets/dashboard/testimonials.json');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', null);
    });

    test(
      'should return cached testimonials when the cache already has data',
      () async {
        cacheDelegateRepository.stubGetTestimonials(testimonials);

        final result = await repository.getTestimonials();

        expect(result, testimonials);
        verify(() => cacheDelegateRepository.getTestimonials()).called(1);
        for (final testimonial in testimonials) {
          verifyNever(
            () => cacheDelegateRepository.cacheTestimonial(testimonial),
          );
        }
      },
    );

    test(
      'should load testimonials from assets and cache them when the cache is empty',
      () async {
        cacheDelegateRepository.stubGetTestimonialsThrows(
          const TestimonialNotFoundException(),
        );
        for (final testimonial in testimonials) {
          cacheDelegateRepository.stubCacheTestimonial(testimonial);
        }

        final result = await repository.getTestimonials();

        expect(result, testimonials);
        for (final testimonial in testimonials) {
          verify(
            () => cacheDelegateRepository.cacheTestimonial(testimonial),
          ).called(1);
        }
      },
    );

    test(
      'should return a single testimonial from assets when it is not cached',
      () async {
        final testimonial = testimonials.first;
        cacheDelegateRepository.stubGetTestimonialThrows(
          id: testimonial.id,
          error: const TestimonialNotFoundException(),
        );
        for (final item in testimonials) {
          cacheDelegateRepository.stubCacheTestimonial(item);
        }

        final result = await repository.getTestimonial(testimonial.id);

        expect(result, testimonial);
        verify(
          () => logReporter.debug(
            'Testimonial ${testimonial.id} not found in cache, loading from assets',
            tag: 'AssetTestimonialRepositoryImpl',
          ),
        ).called(1);
      },
    );

    test(
      'should log the cache error and still load testimonials from assets when the cache throws a cache exception',
      () async {
        cacheDelegateRepository.stubGetTestimonialsThrows(
          const TestimonialCacheException(cause: 'db down'),
        );
        for (final testimonial in testimonials) {
          cacheDelegateRepository.stubCacheTestimonial(testimonial);
        }

        final result = await repository.getTestimonials();

        expect(result, testimonials);
        verify(
          () => logReporter.error(
            'Cache error while getting testimonials: db down',
            tag: 'AssetTestimonialRepositoryImpl',
            stacktrace: any(named: 'stacktrace'),
          ),
        ).called(1);
      },
    );

    test(
      'should log and continue when caching testimonials loaded from assets fails',
      () async {
        cacheDelegateRepository.stubGetTestimonialsThrows(
          const TestimonialNotFoundException(),
        );
        cacheDelegateRepository.stubCacheTestimonialThrows(
          testimonial: testimonials.first,
          error: Exception('cache write failed'),
        );

        final result = await repository.getTestimonials();

        expect(result, testimonials);
        verify(
          () => logReporter.error(
            'Failed to cache testimonials from assets, continuing without caching.',
            tag: 'AssetTestimonialRepositoryImpl',
          ),
        ).called(1);
      },
    );

    test(
      'should throw a parsing exception when the asset payload is invalid',
      () {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMessageHandler('flutter/assets', (message) async {
              final key = const StringCodec().decodeMessage(message);
              if (key == 'assets/dashboard/testimonials.json') {
                return ByteData.sublistView(
                  Uint8List.fromList(utf8.encode('{invalid json')),
                );
              }
              return null;
            });
        cacheDelegateRepository.stubGetTestimonialsThrows(
          const TestimonialNotFoundException(),
        );

        rootBundle.evict('assets/dashboard/testimonials.json');

        expect(
          repository.getTestimonials,
          throwsA(isA<TestimonialParsingException>()),
        );
      },
    );
  });
}
