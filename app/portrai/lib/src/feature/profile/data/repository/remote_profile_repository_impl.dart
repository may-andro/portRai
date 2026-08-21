import 'package:core/core.dart';
import 'package:firebase/firebase.dart';
import 'package:log_reporter/log_reporter.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/profile/data/mapper/_mapper.dart';
import 'package:portrai/src/feature/profile/data/model/_model.dart';
import 'package:portrai/src/feature/profile/data/repository/cache_profile_repository_impl.dart';
import 'package:portrai/src/feature/profile/domain/_domain.dart';

@register
class RemoteProfileRepositoryImpl implements ProfileRepository {
  RemoteProfileRepositoryImpl(
    this._firestoreController,
    this._appLocale,
    @Inject(CacheProfileRepositoryImpl) this._cacheDelegateRepository,
    this._mapper,
    this._logReporter,
  );

  final FbFirestoreController _firestoreController;
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
      final profile = await _loadProfileFromRemote();

      await _cacheProfileSafely(profile);

      return profile;
    } on ProfileCacheException catch (_) {
      _logReporter.error(
        'Cache error while getting profile, loading from remote instead.',
      );

      final profile = await _loadProfileFromRemote();

      return profile;
    }
  }

  Future<ProfileEntity> _loadProfileFromRemote() async {
    try {
      final locale = _appLocale.languageCode;
      final profileJson = await _firestoreController.getDocumentFromCollection(
        'profile',
        locale,
      );

      if (profileJson == null) {
        throw const ProfileNotFoundException(
          cause: 'Profile document not found in Firestore',
        );
      }

      try {
        final profileData = profileJson['profile'] as Map<String, dynamic>;
        // Add locale field for ProfileModel deserialization
        profileData['locale'] = locale;

        final profileModel = ProfileModel.fromJson(profileData);
        return _mapper.to(profileModel);
      } catch (e, st) {
        throw ProfileParsingException(
          cause: 'Failed to parse profile from Firestore: $e',
          stackTrace: st,
        );
      }
    } on ProfileNotFoundException {
      rethrow;
    } on ProfileParsingException {
      rethrow;
    } on FirestoreDocumentNotFoundException catch (e, st) {
      throw ProfileNotFoundException(cause: e, stackTrace: st);
    } on FirestorePermissionDeniedException catch (e, st) {
      throw ProfileUnauthorizedException(cause: e, stackTrace: st);
    } on FirestoreTimeoutException catch (e, st) {
      throw ProfileNetworkException(cause: e, stackTrace: st);
    } on FirestoreInvalidDataException catch (e, st) {
      throw ProfileParsingException(cause: e, stackTrace: st);
    } on FirestoreQuotaExceededException catch (e, st) {
      throw ProfileNetworkException(cause: e, stackTrace: st);
    } on FirestoreNetworkException catch (e, st) {
      throw ProfileNetworkException(cause: e, stackTrace: st);
    } on FirestoreUnknownException catch (e, st) {
      throw ProfileNetworkException(cause: e, stackTrace: st);
    } catch (e, st) {
      throw ProfileParsingException(
        cause: 'Unexpected error while loading profile: $e',
        stackTrace: st,
      );
    }
  }

  Future<void> _cacheProfileSafely(ProfileEntity profile) async {
    try {
      await cacheProfile(profile);
    } catch (_) {
      _logReporter.error(
        'Failed to cache profile from remote, continuing without caching.',
      );
    }
  }
}
