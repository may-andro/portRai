import 'dart:convert';

import 'package:core/core.dart';
import 'package:error_reporter/error_reporter.dart';
import 'package:flutter/services.dart';
import 'package:log_reporter/log_reporter.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/asset_source/asset_source.dart';
import 'package:portrai/src/feature/service/data/mapper/_mapper.dart';
import 'package:portrai/src/feature/service/data/model/_model.dart';
import 'package:portrai/src/feature/service/data/repository/cache_service_repository_impl.dart';
import 'package:portrai/src/feature/service/domain/_domain.dart';

@register
class AssetServiceRepositoryImpl implements ServiceRepository {
  AssetServiceRepositoryImpl(
    this._appLocale,
    @Inject(CacheServiceRepositoryImpl) this._cacheDelegateRepository,
    this._mapper,
    this._logReporter,
    this._errorReporter,
    this._getAssetSourceUseCase,
  );

  static const _logTag = 'AssetServiceRepositoryImpl';

  final AppLocale _appLocale;
  final ServiceRepository _cacheDelegateRepository;
  final ServiceMapper _mapper;
  final LogReporter _logReporter;
  final ErrorReporter _errorReporter;
  final GetAssetSourceUseCase _getAssetSourceUseCase;

  @override
  Future<void> cacheServices(List<ServiceEntity> services) {
    return _cacheDelegateRepository.cacheServices(services);
  }

  @override
  Future<List<ServiceEntity>> getServices() async {
    final source = (await _getAssetSourceUseCase()).right;
    if (source.isTemplate) return await _loadServiceFromAssets(source);

    try {
      final cachedService = await _cacheDelegateRepository.getServices();
      if (cachedService.isNotEmpty) {
        return cachedService;
      }
    } on ServiceNotFoundException catch (_) {
      // Cache is empty for current locale - fall through to load from assets
    } on ServiceCacheException catch (e, stackTrace) {
      _logReporter.error(
        'Cache error while getting services: ${e.cause}',
        tag: _logTag,
        stacktrace: stackTrace,
      );
    }

    final servicesList = await _loadServiceFromAssets(source);

    await _cacheServiceSafely(servicesList);

    return servicesList;
  }

  Future<List<ServiceEntity>> _loadServiceFromAssets(AssetSource source) async {
    try {
      final locale = _appLocale.languageCode;
      final jsonString = await rootBundle.loadString(
        source.assetPath('services'),
      );
      final localeServiceJson =
          (jsonDecode(jsonString) as Map<String, dynamic>)[locale]
              as Map<String, dynamic>;

      final servicesJson = localeServiceJson['services'] as List<dynamic>;

      return servicesJson.map((json) {
        final serviceMap = json as Map<String, dynamic>;

        serviceMap['locale'] = locale;

        return _mapper.to(ServiceModel.fromJson(serviceMap));
      }).toList();
    } catch (e, st) {
      throw ServiceParsingException(
        cause: 'Failed to load services from assets: $e',
        stackTrace: st,
      );
    }
  }

  Future<void> _cacheServiceSafely(List<ServiceEntity> servicesList) async {
    try {
      await cacheServices(servicesList);
    } on ServiceCacheException catch (exception, stackTrace) {
      // Loading still succeeds without the cache, so the failure is reported
      // instead of thrown.
      await _errorReporter.reportError(
        exception: exception,
        stackTrace: stackTrace,
        tag: _logTag,
      );
    }
  }
}
