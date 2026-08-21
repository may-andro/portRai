import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter/services.dart';
import 'package:log_reporter/log_reporter.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/experience/data/mapper/_mapper.dart';
import 'package:portrai/src/feature/experience/data/model/_model.dart';
import 'package:portrai/src/feature/experience/data/repository/cache_experience_repository_impl.dart';
import 'package:portrai/src/feature/experience/domain/_domain.dart';

const String _logTag = 'AssetExperienceRepositoryImpl';

@register
class AssetExperienceRepositoryImpl implements ExperienceRepository {
  AssetExperienceRepositoryImpl(
    this._appLocale,
    @Inject(CacheExperienceRepositoryImpl) this._cacheDelegateRepository,
    this._mapper,
    this._logReporter,
  );

  final AppLocale _appLocale;
  final ExperienceRepository _cacheDelegateRepository;
  final ExperienceMapper _mapper;
  final LogReporter _logReporter;

  @override
  Future<void> cacheExperience(ExperienceEntity experience) {
    return _cacheDelegateRepository.cacheExperience(experience);
  }

  @override
  Future<ExperienceEntity> getExperience(String id) async {
    try {
      return await _cacheDelegateRepository.getExperience(id);
    } on ExperienceNotFoundException catch (_) {
      // Experience not found in cache, load from assets
      final experiences = await _loadExperiencesFromAssets();

      // Try to cache them, but don't fail if caching fails
      await _cacheExperiencesSafely(experiences);

      // Find the requested experience
      final experience = experiences.firstWhereOrNull((exp) => exp.id == id);

      if (experience == null) {
        throw ExperienceNotFoundException(
          cause: 'Experience with id "$id" not found in assets',
        );
      }

      return experience;
    } on ExperienceCacheException catch (e, stackTrace) {
      // Cache has data corruption or DB issues, try loading from assets directly
      _logReporter.error(
        tag: _logTag,
        'Cache error while getting experience "$id": ${e.cause}',
        stacktrace: stackTrace,
      );

      final experiences = await _loadExperiencesFromAssets();

      final experience = experiences.firstWhereOrNull((exp) => exp.id == id);

      if (experience == null) {
        throw ExperienceNotFoundException(
          cause: 'Experience with id "$id" not found in assets',
        );
      }

      return experience;
    }
  }

  @override
  Future<List<ExperienceEntity>> getExperiences() async {
    try {
      final cachedExperiences = await _cacheDelegateRepository.getExperiences();
      if (cachedExperiences.isNotEmpty) {
        return cachedExperiences;
      }
    } on ExperienceNotFoundException catch (_) {
      // Cache is empty for current locale - fall through to load from assets
    } on ExperienceCacheException catch (e, stackTrace) {
      // Cache has issues (DB not initialized, corruption, etc.)
      _logReporter.error(
        tag: _logTag,
        'Cache error while getting experiences: ${e.cause}',
        stacktrace: stackTrace,
      );
      // Fall through to load from assets
    }

    // Cache is empty, expired, or has issues - fetch from assets
    final experiences = await _loadExperiencesFromAssets();

    // Try to cache them, but don't fail if caching fails
    await _cacheExperiencesSafely(experiences);

    return experiences;
  }

  /// Loads experiences from assets file based on app locale
  Future<List<ExperienceEntity>> _loadExperiencesFromAssets() async {
    try {
      final locale = _appLocale.languageCode;
      final jsonString = await rootBundle.loadString(
        'assets/dashboard/experiences.json',
      );
      final localeExperienceJson =
          (jsonDecode(jsonString) as Map<String, dynamic>)[locale]
              as Map<String, dynamic>;

      final experienceJson =
          localeExperienceJson['experiences'] as List<dynamic>;

      return experienceJson.map((json) {
        final experienceMap = json as Map<String, dynamic>;

        experienceMap['locale'] = locale;

        return _mapper.to(ExperienceModel.fromJson(experienceMap));
      }).toList();
    } catch (e, st) {
      throw ExperienceParsingException(
        cause: 'Failed to load experiences from assets: $e',
        stackTrace: st,
      );
    }
  }

  /// Attempts to cache experiences, but doesn't throw if caching fails
  Future<void> _cacheExperiencesSafely(
    List<ExperienceEntity> experiences,
  ) async {
    try {
      for (final experience in experiences) {
        await cacheExperience(experience);
      }
    } catch (_) {
      _logReporter.error(
        tag: _logTag,
        'Failed to cache experiences from assets, continuing without caching.',
      );
    }
  }
}
