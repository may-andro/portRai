import 'package:core/core.dart';
import 'package:firebase/firebase.dart';
import 'package:log_reporter/log_reporter.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/app_config/data/repository/cache_app_config_repository_impl.dart';
import 'package:portrai/src/feature/app_config/domain/_domain.dart';

@Register(as: AppConfigRepository)
class RemoteAppConfigRepositoryImpl implements AppConfigRepository {
  RemoteAppConfigRepositoryImpl(
    this._firestoreController,
    this._buildConfig,
    @Inject(CacheAppConfigRepositoryImpl) this._cacheDelegateRepository,
    this._logReporter,
  );

  static const _collectionPath = 'app_config';

  final FbFirestoreController _firestoreController;
  final BuildConfig _buildConfig;
  final AppConfigRepository _cacheDelegateRepository;
  final LogReporter _logReporter;

  @override
  Future<void> cacheAppConfig(PortraiAppConfig appConfig) {
    return _cacheDelegateRepository.cacheAppConfig(appConfig);
  }

  @override
  Future<PortraiAppConfig> getAppConfig() async {
    try {
      final appConfig = await _loadAppConfigFromRemote();
      await _cacheAppConfigSafely(appConfig);
      return appConfig;
    } on AppConfigException catch (_) {
      _logReporter.error(
        'Failed to load app config from remote, falling back to cache.',
      );
      return _cacheDelegateRepository.getAppConfig();
    }
  }

  Future<PortraiAppConfig> _loadAppConfigFromRemote() async {
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
        return PortraiAppConfig.fromJson(appConfigJson);
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

  /// Caches the app config, but doesn't fail if caching fails.
  Future<void> _cacheAppConfigSafely(PortraiAppConfig appConfig) async {
    try {
      await cacheAppConfig(appConfig);
    } catch (_) {
      _logReporter.error(
        'Failed to cache app config from remote, continuing without caching.',
      );
    }
  }
}
