import 'dart:async';

import 'package:core/core.dart';
import 'package:error_reporter/error_reporter.dart';
import 'package:firebase/firebase.dart';
import 'package:log_reporter/log_reporter.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/app_config/data/mapper/_mapper.dart';
import 'package:portrai/src/feature/app_config/data/model/_model.dart';
import 'package:portrai/src/feature/app_config/data/repository/cache_app_config_repository_impl.dart';
import 'package:portrai/src/feature/app_config/domain/_domain.dart';

@Register(as: AppConfigRepository)
class RemoteAppConfigRepositoryImpl implements AppConfigRepository {
  RemoteAppConfigRepositoryImpl(
    this._firestoreController,
    this._buildConfig,
    @Inject(CacheAppConfigRepositoryImpl) this._cacheDelegateRepository,
    this._mapper,
    this._logReporter,
    this._errorReporter,
  );

  static const _collectionPath = 'app_config';
  static const _tag = 'RemoteAppConfigRepositoryImpl';

  final FbFirestoreController _firestoreController;
  final BuildConfig _buildConfig;
  final AppConfigRepository _cacheDelegateRepository;
  final PortraiAppConfigMapper _mapper;
  final LogReporter _logReporter;
  final ErrorReporter _errorReporter;

  @override
  Future<void> cacheAppConfig(PortraiAppConfigEntity appConfig) {
    return _cacheDelegateRepository.cacheAppConfig(appConfig);
  }

  /// Returns the cached app config when there is one, so start up doesn't
  /// wait for the network, and refreshes the cache from remote for the next
  /// start. Without a cached app config, waits for the remote one.
  @override
  Future<PortraiAppConfigEntity> getAppConfig() async {
    final PortraiAppConfigEntity cachedAppConfig;
    try {
      cachedAppConfig = await _cacheDelegateRepository.getAppConfig();
    } on AppConfigException {
      final appConfig = await _loadAppConfigFromRemote();
      await _cacheAppConfigSafely(appConfig);
      return appConfig;
    }
    unawaited(_refreshCachedAppConfig());
    return cachedAppConfig;
  }

  Future<void> _refreshCachedAppConfig() async {
    try {
      final appConfig = await _loadAppConfigFromRemote();
      await _cacheAppConfigSafely(appConfig);
    } on AppConfigException {
      _logReporter.error(
        'Failed to refresh the cached app config from remote.',
        tag: _tag,
      );
    }
  }

  Future<PortraiAppConfigEntity> _loadAppConfigFromRemote() async {
    try {
      final documentId = _buildConfig.buildEnvironment.name;
      final appConfigJson = await _firestoreController
          .getDocumentFromCollection(_collectionPath, documentId);

      if (appConfigJson == null) {
        throw const AppConfigNotFoundException(
          cause: 'App config document not found in Firestore',
        );
      }

      try {
        return _mapper.to(PortraiAppConfigModel.fromJson(appConfigJson));
      } catch (e, st) {
        throw AppConfigParsingException(
          cause: 'Failed to parse app config from Firestore: $e',
          stackTrace: st,
        );
      }
    } on AppConfigException {
      rethrow;
    } on FirestoreDocumentNotFoundException catch (e, st) {
      throw AppConfigNotFoundException(cause: e, stackTrace: st);
    } on FirestorePermissionDeniedException catch (e, st) {
      throw AppConfigUnauthorizedException(cause: e, stackTrace: st);
    } on FirestoreTimeoutException catch (e, st) {
      throw AppConfigNetworkException(cause: e, stackTrace: st);
    } on FirestoreNetworkException catch (e, st) {
      throw AppConfigNetworkException(cause: e, stackTrace: st);
    } on FirestoreInvalidDataException catch (e, st) {
      throw AppConfigParsingException(cause: e, stackTrace: st);
    } on FirestoreQuotaExceededException catch (e, st) {
      throw AppConfigNetworkException(cause: e, stackTrace: st);
    } catch (e, st) {
      throw AppConfigParsingException(
        cause: 'Unexpected error while loading app config: $e',
        stackTrace: st,
      );
    }
  }

  Future<void> _cacheAppConfigSafely(PortraiAppConfigEntity appConfig) async {
    try {
      await cacheAppConfig(appConfig);
    } on AppConfigCacheException catch (exception, stackTrace) {
      // Loading still succeeds without the cache, so the failure is reported
      // instead of thrown.
      await _errorReporter.reportError(
        exception: exception,
        stackTrace: stackTrace,
        tag: _tag,
      );
    }
  }
}
