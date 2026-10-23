import 'dart:async';

import 'package:core/core.dart';
import 'package:firebase/firebase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/app_config/app_config.dart';
import 'package:portrai/src/feature/app_config/data/mapper/_mapper.dart';
import 'package:portrai/src/feature/app_config/data/repository/remote_app_config_repository_impl.dart';
import 'package:portrai/src/feature/app_config/domain/exception/app_config_exception.dart';

import '../../../../../mock/feature/app_config/domain/entity/fake_portrai_app_config_entity.dart';
import '../../../../../mock/feature/app_config/domain/repository/mock_app_config_repository.dart';
import '../../../../../mock/utility/fake_error_reporter.dart';
import '../../../../../mock/utility/mock_fb_firestore_controller.dart';
import '../../../../../mock/utility/mock_log_reporter.dart';

void main() {
  group('RemoteAppConfigRepositoryImpl', () {
    late MockFbFirestoreController firestoreController;
    late BuildConfig buildConfig;
    late MockAppConfigRepository cacheDelegateRepository;
    late MockLogReporter logReporter;
    late FakeErrorReporter errorReporter;
    late RemoteAppConfigRepositoryImpl repository;

    setUpAll(() {
      registerFallbackValue(FakePortraiAppConfigEntity());
    });

    setUp(() {
      firestoreController = MockFbFirestoreController();
      buildConfig = BuildConfig(buildEnvironment: BuildEnvironment.prod);
      cacheDelegateRepository = MockAppConfigRepository();
      logReporter = MockLogReporter();
      errorReporter = FakeErrorReporter();
      repository = RemoteAppConfigRepositoryImpl(
        firestoreController,
        buildConfig,
        cacheDelegateRepository,
        const PortraiAppConfigMapper(
          AiImageAppConfigMapper(),
          AiRateLimitAppConfigMapper(),
        ),
        logReporter,
        errorReporter,
      );
    });

    group('cacheAppConfig', () {
      test('should delegate caching to the cache repository', () async {
        const appConfig = PortraiAppConfigEntity(
          minimumRequiredAppVersion: '1.0.0',
        );
        cacheDelegateRepository.stubCacheAppConfig();

        await repository.cacheAppConfig(appConfig);

        verify(
          () => cacheDelegateRepository.cacheAppConfig(appConfig),
        ).called(1);
      });
    });

    group('getAppConfig', () {
      const cachedAppConfig = PortraiAppConfigEntity(
        minimumRequiredAppVersion: '0.9.0',
      );
      const remoteAppConfig = PortraiAppConfigEntity(
        minimumRequiredAppVersion: '1.2.3',
      );

      test('should return the cached app config and cache the remote one '
          'when an app config is cached', () async {
        cacheDelegateRepository
          ..stubGetAppConfig(cachedAppConfig)
          ..stubCacheAppConfig();
        firestoreController.stubGetDocumentFromCollection({
          'minimumRequiredAppVersion': '1.2.3',
        });

        final appConfig = await repository.getAppConfig();
        await pumpEventQueue();

        expect(appConfig, cachedAppConfig);
        verify(
          () => cacheDelegateRepository.cacheAppConfig(remoteAppConfig),
        ).called(1);
      });

      test('should return the cached app config without waiting for remote '
          'when an app config is cached', () async {
        cacheDelegateRepository.stubGetAppConfig(cachedAppConfig);
        firestoreController.stubGetDocumentFromCollectionFuture(
          Completer<Map<String, dynamic>?>().future,
        );

        final appConfig = await repository.getAppConfig();

        expect(appConfig, cachedAppConfig);
      });

      test('should log an error and keep the cached app config when the '
          'refresh from remote fails', () async {
        cacheDelegateRepository.stubGetAppConfig(cachedAppConfig);
        firestoreController.stubGetDocumentFromCollectionThrows(
          const FirestoreNetworkException('network error', StackTrace.empty),
        );

        final appConfig = await repository.getAppConfig();
        await pumpEventQueue();

        expect(appConfig, cachedAppConfig);
        verifyNever(() => cacheDelegateRepository.cacheAppConfig(any()));
        verify(
          () => logReporter.error(
            'Failed to refresh the cached app config from remote.',
            tag: 'RemoteAppConfigRepositoryImpl',
          ),
        ).called(1);
      });

      test('should return the remote app config and cache it when no app '
          'config is cached', () async {
        cacheDelegateRepository
          ..stubGetAppConfigThrows(
            const AppConfigNotFoundException(cause: 'no cache'),
          )
          ..stubCacheAppConfig();
        firestoreController.stubGetDocumentFromCollection({
          'minimumRequiredAppVersion': '1.2.3',
        });

        final appConfig = await repository.getAppConfig();

        expect(appConfig, remoteAppConfig);
        verify(
          () => cacheDelegateRepository.cacheAppConfig(remoteAppConfig),
        ).called(1);
      });

      test('should report the error and return the remote app config when '
          'caching it fails', () async {
        cacheDelegateRepository
          ..stubGetAppConfigThrows(
            const AppConfigNotFoundException(cause: 'no cache'),
          )
          ..stubCacheAppConfigThrows(
            const AppConfigCacheException(cause: 'cache write failed'),
          );
        firestoreController.stubGetDocumentFromCollection({
          'minimumRequiredAppVersion': '1.2.3',
        });

        final appConfig = await repository.getAppConfig();

        expect(appConfig, remoteAppConfig);
        final reportedError = errorReporter.reportedErrors.single;
        expect(reportedError.exception, isA<AppConfigCacheException>());
        expect(reportedError.tag, 'RemoteAppConfigRepositoryImpl');
      });

      test('should throw a not found exception when no app config is cached '
          'and the remote document does not exist', () {
        cacheDelegateRepository.stubGetAppConfigThrows(
          const AppConfigNotFoundException(cause: 'no cache'),
        );
        firestoreController.stubGetDocumentFromCollection(null);

        expect(
          repository.getAppConfig,
          throwsA(isA<AppConfigNotFoundException>()),
        );
      });

      test('should throw a parsing exception when no app config is cached '
          'and the remote document has invalid data', () {
        cacheDelegateRepository.stubGetAppConfigThrows(
          const AppConfigNotFoundException(cause: 'no cache'),
        );
        firestoreController.stubGetDocumentFromCollection({
          'unexpectedField': 'value',
        });

        expect(
          repository.getAppConfig,
          throwsA(isA<AppConfigParsingException>()),
        );
      });

      test('should throw a network exception when no app config is cached '
          'and the remote load fails on the network', () {
        cacheDelegateRepository.stubGetAppConfigThrows(
          const AppConfigNotFoundException(cause: 'no cache'),
        );
        firestoreController.stubGetDocumentFromCollectionThrows(
          const FirestoreNetworkException('network error', StackTrace.empty),
        );

        expect(
          repository.getAppConfig,
          throwsA(isA<AppConfigNetworkException>()),
        );
      });
    });
  });
}
