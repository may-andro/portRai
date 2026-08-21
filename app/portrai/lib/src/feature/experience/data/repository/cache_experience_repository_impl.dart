import 'package:cache/cache.dart';
import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/experience/data/cache/_cache.dart';
import 'package:portrai/src/feature/experience/data/mapper/_mapper.dart';
import 'package:portrai/src/feature/experience/domain/_domain.dart';

@register
class CacheExperienceRepositoryImpl implements ExperienceRepository {
  CacheExperienceRepositoryImpl(
    this._experienceCache,
    this._mapper,
    this._appLocale,
  );

  final ExperienceCache _experienceCache;
  final ExperienceMapper _mapper;
  final AppLocale _appLocale;

  @override
  Future<void> cacheExperience(ExperienceEntity experience) async {
    try {
      return await _experienceCache.put(_mapper.from(experience));
    } on DBNotInitialisedException catch (e, stackTrace) {
      throw ExperienceCacheException(
        cause: 'Database not initialized: $e',
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw ExperienceCacheException(
        cause: 'Unexpected error while caching experience: $e',
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<ExperienceEntity> getExperience(String id) async {
    try {
      if (id.trim().isEmpty) {
        throw const ExperienceNotFoundException(
          cause: 'Experience ID cannot be empty',
        );
      }

      final currentLocale = _appLocale.languageCode;

      final experience = await _experienceCache.get(
        conditions: {'id': id, 'locale': currentLocale},
      );

      if (experience == null) {
        throw ExperienceNotFoundException(
          cause:
              'Experience with id "$id" not found in cache for current locale',
        );
      }

      return _mapper.to(experience);
    } on ExperienceNotFoundException {
      rethrow;
    } on DBNotInitialisedException catch (e, stackTrace) {
      throw ExperienceCacheException(
        cause: 'Database not initialized: $e',
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw ExperienceNotFoundException(
        cause: 'Unexpected error while retrieving experience: $e',
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<ExperienceEntity>> getExperiences() async {
    try {
      final currentLocale = _appLocale.languageCode;

      final experiences = await _experienceCache.query(
        conditions: {'locale': currentLocale},
      );

      if (experiences.isEmpty) {
        throw const ExperienceNotFoundException(
          cause: 'No experiences found in cache for current locale',
        );
      }

      return experiences.map(_mapper.to).toList();
    } on ExperienceNotFoundException {
      rethrow;
    } on DBNotInitialisedException catch (e, stackTrace) {
      throw ExperienceCacheException(
        cause: 'Database not initialized: $e',
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw ExperienceNotFoundException(
        cause: 'Unexpected error while retrieving experiences: $e',
        stackTrace: stackTrace,
      );
    }
  }
}
