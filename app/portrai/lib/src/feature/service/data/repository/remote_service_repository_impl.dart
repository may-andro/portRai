import 'package:core/core.dart';
import 'package:firebase/firebase.dart';
import 'package:log_reporter/log_reporter.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/service/data/mapper/_mapper.dart';
import 'package:portrai/src/feature/service/data/model/_model.dart';
import 'package:portrai/src/feature/service/data/repository/cache_service_repository_impl.dart';
import 'package:portrai/src/feature/service/domain/_domain.dart';

@register
class RemoteServiceRepositoryImpl implements ServiceRepository {
  RemoteServiceRepositoryImpl(
    this._firestoreController,
    this._appLocale,
    @Inject(CacheServiceRepositoryImpl) this._cacheDelegateRepository,
    this._mapper,
    this._logReporter,
  );

  final FbFirestoreController _firestoreController;
  final AppLocale _appLocale;
  final ServiceRepository _cacheDelegateRepository;
  final ServiceMapper _mapper;
  final LogReporter _logReporter;

  @override
  Future<void> cacheService(ServiceEntity expert) {
    return _cacheDelegateRepository.cacheService(expert);
  }

  @override
  Future<List<ServiceEntity>> getServices() async {
    try {
      final cachedService = await _cacheDelegateRepository.getServices();
      if (cachedService.isNotEmpty) {
        return cachedService;
      }
    } on ServiceNotFoundException catch (_) {
      // Cache is empty for current locale - fall through to load from remote
    } on ServiceCacheException catch (_) {
      _logReporter.error(
        'Cache error while getting services, loading from remote instead.',
      );
    }

    final services = await _loadServiceFromRemote();

    await _cacheServiceSafely(services);

    return services;
  }

  Future<List<ServiceEntity>> _loadServiceFromRemote() async {
    try {
      final locale = _appLocale.languageCode;
      final servicesJson = await _firestoreController.getDocumentFromCollection(
        'services',
        locale,
      );

      if (servicesJson == null) {
        throw const ServiceNotFoundException(
          cause: 'Service document not found in Firestore',
        );
      }

      try {
        final servicesListJson = servicesJson['services'] as List<dynamic>;
        final services = servicesListJson.map((json) {
          final serviceMap = json as Map<String, dynamic>;

          serviceMap['locale'] = locale;

          final service = ServiceModel.fromJson(serviceMap);
          return _mapper.to(service);
        }).toList();

        return services;
      } catch (e, st) {
        throw ServiceParsingException(
          cause: 'Failed to parse services from Firestore: $e',
          stackTrace: st,
        );
      }
    } on ServiceNotFoundException {
      rethrow;
    } on ServiceParsingException {
      rethrow;
    } on FirestoreDocumentNotFoundException catch (e, st) {
      throw ServiceNotFoundException(cause: e, stackTrace: st);
    } on FirestorePermissionDeniedException catch (e, st) {
      throw ServiceUnauthorizedException(cause: e, stackTrace: st);
    } on FirestoreTimeoutException catch (e, st) {
      throw ServiceNetworkException(cause: e, stackTrace: st);
    } on FirestoreInvalidDataException catch (e, st) {
      throw ServiceParsingException(cause: e, stackTrace: st);
    } on FirestoreQuotaExceededException catch (e, st) {
      throw ServiceNetworkException(cause: e, stackTrace: st);
    } catch (e, st) {
      throw ServiceParsingException(
        cause: 'Unexpected error while loading services: $e',
        stackTrace: st,
      );
    }
  }

  Future<void> _cacheServiceSafely(List<ServiceEntity> services) async {
    try {
      for (final services in services) {
        await cacheService(services);
      }
    } catch (_) {
      _logReporter.error(
        'Failed to cache services from remote, continuing without caching.',
      );
    }
  }
}
