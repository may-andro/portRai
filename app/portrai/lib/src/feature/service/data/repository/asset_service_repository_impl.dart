import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter/services.dart';
import 'package:log_reporter/log_reporter.dart';
import 'package:module_injector/module_injector.dart';
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
  );

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
      // Cache is empty for current locale - fall through to load from assets
    } on ServiceCacheException catch (e, stackTrace) {
      _logReporter.error(
        'Cache error while getting services: ${e.cause}',
        stacktrace: stackTrace,
      );
    }

    final servicesList = await _loadServiceFromAssets();

    await _cacheServiceSafely(servicesList);

    return servicesList;
  }

  Future<List<ServiceEntity>> _loadServiceFromAssets() async {
    try {
      final locale = _appLocale.languageCode;
      final jsonString = await rootBundle.loadString(
        'assets/dashboard/services.json',
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
      for (final services in servicesList) {
        await cacheService(services);
      }
    } catch (_) {
      _logReporter.error(
        'Failed to cache services from assets, continuing without caching.',
      );
    }
  }
}
