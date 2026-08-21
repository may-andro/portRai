import 'package:core/core.dart';
import 'package:firebase/firebase.dart';
import 'package:log_reporter/log_reporter.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/expertise/data/mapper/_mapper.dart';
import 'package:portrai/src/feature/expertise/data/model/_model.dart';
import 'package:portrai/src/feature/expertise/data/repository/cache_expertise_repository_impl.dart';
import 'package:portrai/src/feature/expertise/domain/_domain.dart';

@register
class RemoteExpertiseRepositoryImpl implements ExpertiseRepository {
  RemoteExpertiseRepositoryImpl(
    this._firestoreController,
    this._appLocale,
    @Inject(CacheExpertiseRepositoryImpl) this._cacheDelegateRepository,
    this._mapper,
    this._logReporter,
  );

  final FbFirestoreController _firestoreController;
  final AppLocale _appLocale;
  final ExpertiseRepository _cacheDelegateRepository;
  final ExpertiseMapper _mapper;
  final LogReporter _logReporter;

  @override
  Future<void> cacheExpertise(ExpertiseEntity expert) {
    return _cacheDelegateRepository.cacheExpertise(expert);
  }

  @override
  Future<List<ExpertiseEntity>> getAllExpertise() async {
    try {
      final cachedExpertise = await _cacheDelegateRepository.getAllExpertise();
      if (cachedExpertise.isNotEmpty) {
        return cachedExpertise;
      }
    } on ExpertiseNotFoundException catch (_) {
      // Cache is empty for current locale - fall through to load from remote
    } on ExpertiseCacheException catch (_) {
      _logReporter.error(
        'Cache error while getting expertise, loading from remote instead.',
      );
    }

    final expertiseList = await _loadExpertiseFromRemote();

    await _cacheExpertiseSafely(expertiseList);

    return expertiseList;
  }

  Future<List<ExpertiseEntity>> _loadExpertiseFromRemote() async {
    try {
      final locale = _appLocale.languageCode;
      final expertiseJson = await _firestoreController
          .getDocumentFromCollection('expertise', locale);

      if (expertiseJson == null) {
        throw const ExpertiseNotFoundException(
          cause: 'Expertise document not found in Firestore',
        );
      }

      try {
        final expertiesJson = expertiseJson['experties'] as List<dynamic>;
        final expertiseList = expertiesJson.map((json) {
          final expertiseMap = json as Map<String, dynamic>;
          expertiseMap['locale'] = locale;

          final expertiseModel = ExpertiseModel.fromJson(expertiseMap);
          return _mapper.to(expertiseModel);
        }).toList();

        return expertiseList;
      } catch (e, st) {
        throw ExpertiseParsingException(
          cause: 'Failed to parse expertise from Firestore: $e',
          stackTrace: st,
        );
      }
    } on ExpertiseNotFoundException {
      rethrow;
    } on ExpertiseParsingException {
      rethrow;
    } on FirestoreDocumentNotFoundException catch (e, st) {
      throw ExpertiseNotFoundException(cause: e, stackTrace: st);
    } on FirestorePermissionDeniedException catch (e, st) {
      throw ExpertiseUnauthorizedException(cause: e, stackTrace: st);
    } on FirestoreTimeoutException catch (e, st) {
      throw ExpertiseNetworkException(cause: e, stackTrace: st);
    } on FirestoreInvalidDataException catch (e, st) {
      throw ExpertiseParsingException(cause: e, stackTrace: st);
    } on FirestoreQuotaExceededException catch (e, st) {
      throw ExpertiseNetworkException(cause: e, stackTrace: st);
    } catch (e, st) {
      throw ExpertiseParsingException(
        cause: 'Unexpected error while loading expertise: $e',
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
        'Failed to cache expertise from remote, continuing without caching.',
      );
    }
  }
}
