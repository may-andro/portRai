import 'dart:convert';
import 'package:core/core.dart';
import 'package:flutter/services.dart';
import 'package:log_reporter/log_reporter.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/asset_source/asset_source.dart';
import 'package:portrai/src/feature/expertise/data/mapper/_mapper.dart';
import 'package:portrai/src/feature/expertise/data/model/_model.dart';
import 'package:portrai/src/feature/expertise/data/repository/cache_expertise_repository_impl.dart';
import 'package:portrai/src/feature/expertise/domain/_domain.dart';

const String _logTag = 'AssetExpertiseRepositoryImpl';

@register
class AssetExpertiseRepositoryImpl implements ExpertiseRepository {
  AssetExpertiseRepositoryImpl(
    this._appLocale,
    @Inject(CacheExpertiseRepositoryImpl) this._cacheDelegateRepository,
    this._mapper,
    this._logReporter,
    this._getAssetSourceUseCase,
  );

  final AppLocale _appLocale;
  final ExpertiseRepository _cacheDelegateRepository;
  final ExpertiseMapper _mapper;
  final LogReporter _logReporter;
  final GetAssetSourceUseCase _getAssetSourceUseCase;

  @override
  Future<void> cacheExpertise(ExpertiseEntity expert) {
    return _cacheDelegateRepository.cacheExpertise(expert);
  }

  @override
  Future<List<ExpertiseEntity>> getAllExpertise() async {
    final source = (await _getAssetSourceUseCase()).right;
    if (source.isTemplate) return await _loadExpertiseFromAssets(source);

    try {
      final cachedExpertise = await _cacheDelegateRepository.getAllExpertise();
      if (cachedExpertise.isNotEmpty) {
        return cachedExpertise;
      }
    } on ExpertiseNotFoundException catch (_) {
      // Cache is empty for current locale - fall through to load from assets
    } on ExpertiseCacheException catch (e, stackTrace) {
      _logReporter.error(
        tag: _logTag,
        'Cache error while getting expertise: ${e.cause}',
        stacktrace: stackTrace,
      );
    }

    final expertiseList = await _loadExpertiseFromAssets(source);

    await _cacheExpertiseSafely(expertiseList);

    return expertiseList;
  }

  Future<List<ExpertiseEntity>> _loadExpertiseFromAssets(
    AssetSource source,
  ) async {
    try {
      final locale = _appLocale.languageCode;
      // Load JSON from assets file
      final jsonString = await rootBundle.loadString(
        source.assetPath('expertise'),
      );
      final localeExpertiseJson =
          (jsonDecode(jsonString) as Map<String, dynamic>)[locale]
              as Map<String, dynamic>;

      final expertiseJson = localeExpertiseJson['experties'] as List<dynamic>;

      return expertiseJson.map((json) {
        final expertiseMap = json as Map<String, dynamic>;
        expertiseMap['locale'] = locale;

        return _mapper.to(ExpertiseModel.fromJson(expertiseMap));
      }).toList();
    } catch (e, st) {
      throw ExpertiseParsingException(
        cause: 'Failed to load expertise from assets: $e',
        stackTrace: st,
      );
    }
  }

  Future<void> _cacheExpertiseSafely(
    List<ExpertiseEntity> expertiseList,
  ) async {
    try {
      for (final expertise in expertiseList) {
        await cacheExpertise(expertise);
      }
    } catch (_) {
      _logReporter.error(
        tag: _logTag,
        'Failed to cache expertise from assets, continuing without caching.',
      );
    }
  }
}
