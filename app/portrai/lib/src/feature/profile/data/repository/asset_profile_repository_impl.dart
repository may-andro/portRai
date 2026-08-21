import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter/services.dart';
import 'package:log_reporter/log_reporter.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/profile/data/mapper/_mapper.dart';
import 'package:portrai/src/feature/profile/data/model/_model.dart';
import 'package:portrai/src/feature/profile/data/repository/cache_profile_repository_impl.dart';
import 'package:portrai/src/feature/profile/domain/_domain.dart';

@register
class AssetProfileRepositoryImpl implements ProfileRepository {
  AssetProfileRepositoryImpl(
    this._appLocale,
    @Inject(CacheProfileRepositoryImpl) this._cacheDelegateRepository,
    this._mapper,
    this._logReporter,
  );

  final AppLocale _appLocale;
  final ProfileRepository _cacheDelegateRepository;
  final ProfileMapper _mapper;
  final LogReporter _logReporter;

  @override
  Future<void> cacheProfile(ProfileEntity profile) {
    return _cacheDelegateRepository.cacheProfile(profile);
  }

  @override
  Future<ProfileEntity> getProfile() async {
    try {
      return await _cacheDelegateRepository.getProfile();
    } on ProfileNotFoundException catch (_) {
      final profile = await _loadProfileFromAssets();

      await _cacheProfileSafely(profile);

      return profile;
    } on ProfileCacheException catch (e, stackTrace) {
      _logReporter.error(
        'Cache error while getting profile: ${e.cause}',
        stacktrace: stackTrace,
      );

      final profile = await _loadProfileFromAssets();

      return profile;
    }
  }

  Future<ProfileEntity> _loadProfileFromAssets() async {
    try {
      final locale = _appLocale.languageCode;
      final jsonString = await rootBundle.loadString(
        'assets/dashboard/profile.json',
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
    } catch (_) {
      _logReporter.error(
        'Failed to cache profile from assets, continuing without caching.',
      );
    }
  }
}
