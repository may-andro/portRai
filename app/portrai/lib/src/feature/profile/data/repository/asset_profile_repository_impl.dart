import 'dart:convert';

import 'package:core/core.dart';
import 'package:error_reporter/error_reporter.dart';
import 'package:flutter/services.dart';
import 'package:log_reporter/log_reporter.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/asset_source/asset_source.dart';
import 'package:portrai/src/feature/profile/data/mapper/_mapper.dart';
import 'package:portrai/src/feature/profile/data/model/_model.dart';
import 'package:portrai/src/feature/profile/data/repository/cache_profile_repository_impl.dart';
import 'package:portrai/src/feature/profile/domain/_domain.dart';

const _logTag = 'AssetProfileRepositoryImpl';

@register
class AssetProfileRepositoryImpl implements ProfileRepository {
  AssetProfileRepositoryImpl(
    this._appLocale,
    @Inject(CacheProfileRepositoryImpl) this._cacheDelegateRepository,
    this._mapper,
    this._logReporter,
    this._errorReporter,
    this._getAssetSourceUseCase,
  );

  final AppLocale _appLocale;
  final ProfileRepository _cacheDelegateRepository;
  final ProfileMapper _mapper;
  final LogReporter _logReporter;
  final ErrorReporter _errorReporter;
  final GetAssetSourceUseCase _getAssetSourceUseCase;

  @override
  Future<void> cacheProfile(ProfileEntity profile) {
    return _cacheDelegateRepository.cacheProfile(profile);
  }

  @override
  Future<ProfileEntity> getProfile() async {
    final source = (await _getAssetSourceUseCase()).right;
    if (source.isTemplate) return await _loadProfileFromAssets(source);

    try {
      return await _cacheDelegateRepository.getProfile();
    } on ProfileNotFoundException catch (_) {
      final profile = await _loadProfileFromAssets(source);

      await _cacheProfileSafely(profile);

      return profile;
    } on ProfileCacheException catch (e, stackTrace) {
      _logReporter.error(
        'Cache error while getting profile: ${e.cause}',
        stacktrace: stackTrace,
        tag: _logTag,
      );

      final profile = await _loadProfileFromAssets(source);

      return profile;
    }
  }

  Future<ProfileEntity> _loadProfileFromAssets(AssetSource source) async {
    try {
      final locale = _appLocale.languageCode;
      final jsonString = await rootBundle.loadString(
        source.assetPath('profile'),
      );
      final localeProfileJson =
          (jsonDecode(jsonString) as Map<String, dynamic>)[locale]
              as Map<String, dynamic>;

      final profileJson = localeProfileJson['profile'] as Map<String, dynamic>;
      profileJson['locale'] = locale;

      return _mapper.to(ProfileModel.fromJson(profileJson));
    } catch (e, st) {
      throw ProfileParsingException(
        cause: 'Failed to load profile from assets: $e',
        stackTrace: st,
      );
    }
  }

  /// Attempts to cache profile, but doesn't throw if caching fails
  Future<void> _cacheProfileSafely(ProfileEntity profile) async {
    try {
      await cacheProfile(profile);
    } on ProfileCacheException catch (exception, stackTrace) {
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
