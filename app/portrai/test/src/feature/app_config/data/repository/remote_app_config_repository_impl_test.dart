import 'package:core/core.dart';
import 'package:firebase/firebase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/app_config/app_config.dart';
import 'package:portrai/src/feature/app_config/data/repository/remote_app_config_repository_impl.dart';
import 'package:portrai/src/feature/app_config/domain/exception/app_config_exception.dart';

import '../../../../../mock/feature/app_config/domain/entity/fake_portrai_app_config.dart';
import '../../../../../mock/feature/app_config/domain/repository/mock_app_config_repository.dart';
import '../../../../../mock/utility/mock_fb_firestore_controller.dart';
import '../../../../../mock/utility/mock_log_reporter.dart';

void main() {
  group('RemoteAppConfigRepositoryImpl', () {
    late MockFbFirestoreController firestoreController;
    late BuildConfig buildConfig;
    late MockAppConfigRepository cacheDelegateRepository;
    late MockLogReporter logReporter;
    late RemoteAppConfigRepositoryImpl repository;

    setUpAll(() {
      registerFallbackValue(FakePortraiAppConfig());
    });

    setUp(() {
      firestoreController = MockFbFirestoreController();
      buildConfig = BuildConfig(buildEnvironment: BuildEnvironment.prod);
      cacheDelegateRepository = MockAppConfigRepository();
      logReporter = MockLogReporter();
      repository = RemoteAppConfigRepositoryImpl(
        firestoreController,
        buildConfig,
        cacheDelegateRepository,
        logReporter,
      );
    });

    group('cacheAppConfig', () {
      test('should delegate caching to the cache repository', () async {
        const appConfig = PortraiAppConfig(minimumRequiredAppVersion: '1.0.0');
        cacheDelegateRepository.stubCacheAppConfig();

        await repository.cacheAppConfig(appConfig);

        verify(
          () => cacheDelegateRepository.cacheAppConfig(appConfig),
        ).called(1);
      });
    });

    group('getAppConfig', () {
      test('should return the remote app config and cache it when the '
          'document exists', () async {
        firestoreController.stubGetDocumentFromCollection({
          'minimumRequiredAppVersion': '1.2.3',
        });
        cacheDelegateRepository.stubCacheAppConfig();

        final result = await repository.getAppConfig();

        expect(
          result,
          const PortraiAppConfig(minimumRequiredAppVersion: '1.2.3'),
        );
        verify(
          () => cacheDelegateRepository.cacheAppConfig(
            const PortraiAppConfig(minimumRequiredAppVersion: '1.2.3'),
          ),
        ).called(1);
      });

      test('should fall back to cache and log a warning when the remote '
          'document does not exist', () async {
        firestoreController.stubGetDocumentFromCollection(null);
        const cachedAppConfig = PortraiAppConfig(
          minimumRequiredAppVersion: '0.9.0',
        );
        cacheDelegateRepository.stubGetAppConfig(cachedAppConfig);

        final result = await repository.getAppConfig();

        expect(result, cachedAppConfig);
        verify(
          () => logReporter.error(
            'Failed to load app config from remote, falling back to cache.',
          ),
        ).called(1);
      });

      test('should fall back to cache when the remote document has invalid '
          'data', () async {
        firestoreController.stubGetDocumentFromCollection({
          'unexpectedField': 'value',
        });
        const cachedAppConfig = PortraiAppConfig(
          minimumRequiredAppVersion: '0.9.0',
        );
        cacheDelegateRepository.stubGetAppConfig(cachedAppConfig);

        final result = await repository.getAppConfig();

        expect(result, cachedAppConfig);
      });

      test(
        'should fall back to cache when the firestore controller throws',
        () async {
          firestoreController.stubGetDocumentFromCollectionThrows(
            const FirestoreNetworkException('network error', StackTrace.empty),
          );
          const cachedAppConfig = PortraiAppConfig(
            minimumRequiredAppVersion: '0.9.0',
          );
          cacheDelegateRepository.stubGetAppConfig(cachedAppConfig);

          final result = await repository.getAppConfig();

          expect(result, cachedAppConfig);
        },
      );

      test('should not cache silently when caching after a successful remote '
          'load fails', () async {
        firestoreController.stubGetDocumentFromCollection({
          'minimumRequiredAppVersion': '1.2.3',
        });
        cacheDelegateRepository.stubCacheAppConfigThrows(
          Exception('cache write failed'),
        );

        final result = await repository.getAppConfig();

        expect(
          result,
          const PortraiAppConfig(minimumRequiredAppVersion: '1.2.3'),
        );
        verify(
          () => logReporter.error(
            'Failed to cache app config from remote, continuing without '
            'caching.',
          ),
        ).called(1);
      });

      test('should rethrow when both remote and cache fail', () {
        firestoreController.stubGetDocumentFromCollectionThrows(
          Exception('boom'),
        );
        cacheDelegateRepository.stubGetAppConfigThrows(
          const AppConfigNotFoundException(cause: 'no cache either'),
        );

        expect(
          repository.getAppConfig,
          throwsA(isA<AppConfigNotFoundException>()),
        );
      });
    });
  });
}
