import 'package:core/core.dart';
import 'package:firebase/firebase.dart';
import 'package:log_reporter/log_reporter.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/experience/data/mapper/_mapper.dart';
import 'package:portrai/src/feature/experience/data/model/_model.dart';
import 'package:portrai/src/feature/experience/data/repository/cache_experience_repository_impl.dart';
import 'package:portrai/src/feature/experience/domain/_domain.dart';

@register
class RemoteExperienceRepositoryImpl implements ExperienceRepository {
  RemoteExperienceRepositoryImpl(
    this._firestoreController,
    this._appLocale,
    @Inject(CacheExperienceRepositoryImpl) this._cacheDelegateRepository,
    this._mapper,
    this._logReporter,
  );

  final FbFirestoreController _firestoreController;
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
      final experiences = await _loadExperiencesFromRemote();

      // Try to cache them, but don't fail if caching fails
      await _cacheExperiencesSafely(experiences);

      // Find the requested experience
      final experience = experiences.firstWhereOrNull((exp) => exp.id == id);

      if (experience == null) {
        throw ExperienceNotFoundException(
          cause: 'Experience with id "$id" not found in remote',
        );
      }

      return experience;
    } on ExperienceCacheException catch (_) {
      // Cache has data corruption or DB issues, try loading from remote directly
      final experiences = await _loadExperiencesFromRemote();

      final experience = experiences.firstWhereOrNull((exp) => exp.id == id);

      if (experience == null) {
        throw ExperienceNotFoundException(
          cause: 'Experience with id "$id" not found in remote',
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
      // Cache is empty for current locale - fall through to load from remote
    } on ExperienceCacheException catch (_) {
      _logReporter.error(
        'Cache error while getting experiences, loading from remote instead.',
      );
    }

    // Cache is empty, expired, or has issues - fetch from remote
    final experiences = await _loadExperiencesFromRemote();

    // Try to cache them, but don't fail if caching fails
    await _cacheExperiencesSafely(experiences);

    return experiences;
  }

  /// Loads experiences from Firestore based on app locale
  Future<List<ExperienceEntity>> _loadExperiencesFromRemote() async {
    try {
      final locale = _appLocale.languageCode;
      final experienceJson = await _firestoreController
          .getDocumentFromCollection('experiences', locale);

      if (experienceJson == null) {
        throw const ExperienceNotFoundException(
          cause: 'Experience document not found in Firestore',
        );
      }

      try {
        final experiencesJson = experienceJson['experiences'] as List<dynamic>;
        final experiences = experiencesJson.map((json) {
          final experienceMap = json as Map<String, dynamic>;
          experienceMap['locale'] = locale;

          final experienceModel = ExperienceModel.fromJson(experienceMap);
          return _mapper.to(experienceModel);
        }).toList();

        return experiences;
      } catch (e, st) {
        throw ExperienceParsingException(
          cause: 'Failed to parse experiences from Firestore: $e',
          stackTrace: st,
        );
      }
    } on ExperienceNotFoundException {
      rethrow;
    } on ExperienceParsingException {
      rethrow;
    } on FirestoreDocumentNotFoundException catch (e, st) {
      throw ExperienceNotFoundException(cause: e, stackTrace: st);
    } on FirestorePermissionDeniedException catch (e, st) {
      throw ExperienceUnauthorizedException(cause: e, stackTrace: st);
    } on FirestoreTimeoutException catch (e, st) {
      throw ExperienceNetworkException(cause: e, stackTrace: st);
    } on FirestoreInvalidDataException catch (e, st) {
      throw ExperienceParsingException(cause: e, stackTrace: st);
    } on FirestoreQuotaExceededException catch (e, st) {
      throw ExperienceNetworkException(cause: e, stackTrace: st);
    } catch (e, st) {
      throw ExperienceParsingException(
        cause: 'Unexpected error while loading experiences: $e',
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
        'Failed to cache experiences from remote, continuing without caching.',
      );
    }
  }
}
