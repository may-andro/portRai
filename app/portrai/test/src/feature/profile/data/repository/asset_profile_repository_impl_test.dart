import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/profile/data/mapper/_mapper.dart';
import 'package:portrai/src/feature/profile/data/repository/asset_profile_repository_impl.dart';
import 'package:portrai/src/feature/profile/domain/_domain.dart';

import '../../../../../mock/feature/profile/domain/repository/mock_profile_repository.dart';
import '../../../../../mock/feature/profile/test_data/profile_test_data.dart';
import '../../../../../mock/utility/mock_log_reporter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const localeCode = 'en';
  final appLocale = AppLocale(localeCode);
  final mapper = ProfileMapper(
    publishedAtMapper: const PublishedAtMapper(),
    resumeMapper: const ResumeMapper(),
    socialLinkMapper: const SocialLinkMapper(),
    availabilityMapper: const AvailabilityMapper(),
    workingHoursMapper: const WorkingHoursMapper(),
    locationMapper: const LocationMapper(
      coordinatesMapper: CoordinatesMapper(),
    ),
    languageMapper: const LanguageMapper(),
    educationMapper: const EducationMapper(),
    appLocale: appLocale,
  );
  final profile = createProfileEntity();
  final assetsJson = jsonEncode(createProfileAssetJson());

  ByteData assetResponse() =>
      ByteData.sublistView(Uint8List.fromList(utf8.encode(assetsJson)));

  group('AssetProfileRepositoryImpl', () {
    late MockProfileRepository cacheDelegateRepository;
    late MockLogReporter logReporter;
    late AssetProfileRepositoryImpl repository;

    setUp(() {
      cacheDelegateRepository = MockProfileRepository();
      logReporter = MockLogReporter();
      repository = AssetProfileRepositoryImpl(
        appLocale,
        cacheDelegateRepository,
        mapper,
        logReporter,
      );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', (message) async {
            final key = const StringCodec().decodeMessage(message);
            if (key == 'assets/dashboard/profile.json') {
              return assetResponse();
            }
            return null;
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', null);
    });

    test(
      'should return the cached profile when the cache already has data',
      () async {
        cacheDelegateRepository.stubGetProfile(profile);

        final result = await repository.getProfile();

        expect(result, profile);
        verify(() => cacheDelegateRepository.getProfile()).called(1);
        verifyNever(() => cacheDelegateRepository.cacheProfile(profile));
      },
    );

    test(
      'should load the profile from assets and cache it when the cache is empty',
      () async {
        cacheDelegateRepository.stubGetProfileThrows(
          const ProfileNotFoundException(),
        );
        cacheDelegateRepository.stubCacheProfile(profile);

        final result = await repository.getProfile();

        expect(result, profile);
        verify(() => cacheDelegateRepository.cacheProfile(profile)).called(1);
      },
    );

    test(
      'should log the cache error and still load the profile from assets when the cache throws a cache exception',
      () async {
        cacheDelegateRepository.stubGetProfileThrows(
          const ProfileCacheException(cause: 'db down'),
        );

        final result = await repository.getProfile();

        expect(result, profile);
        verify(
          () => logReporter.error(
            'Cache error while getting profile: db down',
            tag: 'AssetProfileRepositoryImpl',
            stacktrace: any(named: 'stacktrace'),
          ),
        ).called(1);
      },
    );

    test(
      'should log and continue when caching the asset profile fails',
      () async {
        cacheDelegateRepository.stubGetProfileThrows(
          const ProfileNotFoundException(),
        );
        cacheDelegateRepository.stubCacheProfileThrows(
          profile: profile,
          error: Exception('cache write failed'),
        );

        final result = await repository.getProfile();

        expect(result, profile);
        verify(
          () => logReporter.error(
            'Failed to cache profile from assets, continuing without caching.',
            tag: 'AssetProfileRepositoryImpl',
          ),
        ).called(1);
      },
    );

    test(
      'should throw a parsing exception when the asset payload is invalid',
      () {
        cacheDelegateRepository.stubGetProfileThrows(
          const ProfileNotFoundException(),
        );
        final invalidLocaleRepository = AssetProfileRepositoryImpl(
          AppLocale('fr'),
          cacheDelegateRepository,
          mapper,
          logReporter,
        );

        expect(
          invalidLocaleRepository.getProfile(),
          throwsA(isA<ProfileParsingException>()),
        );
      },
    );
  });
}
