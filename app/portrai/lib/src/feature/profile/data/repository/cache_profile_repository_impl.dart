import 'package:cache/cache.dart';
import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/profile/data/cache/_cache.dart';
import 'package:portrai/src/feature/profile/data/mapper/_mapper.dart';
import 'package:portrai/src/feature/profile/domain/_domain.dart';

@register
class CacheProfileRepositoryImpl implements ProfileRepository {
  CacheProfileRepositoryImpl(this._profileCache, this._mapper, this._appLocale);

  final ProfileCache _profileCache;
  final ProfileMapper _mapper;
  final AppLocale _appLocale;

  @override
  Future<void> cacheProfile(ProfileEntity profile) async {
    try {
      return await _profileCache.put(_mapper.from(profile));
    } on DBNotInitialisedException catch (e, stackTrace) {
      throw ProfileCacheException(
        cause: 'Database not initialized: $e',
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw ProfileCacheException(
        cause: 'Unexpected error while caching Profile: $e',
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<ProfileEntity> getProfile() async {
    try {
      final currentLocale = _appLocale.languageCode;

      final profile = await _profileCache.get(
        conditions: {'locale': currentLocale},
      );

      if (profile == null) {
        throw const ProfileNotFoundException(
          cause: 'Profile not found in cache for current locale',
        );
      }

      return _mapper.to(profile);
    } on ProfileNotFoundException {
      rethrow;
    } on DBNotInitialisedException catch (e, stackTrace) {
      throw ProfileCacheException(
        cause: 'Database not initialized: $e',
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      // Handle any other unexpected errors
      throw ProfileCacheException(
        cause: 'Unexpected error while retrieving Profile: $e',
        stackTrace: stackTrace,
      );
    }
  }
}
