import 'package:cache/cache.dart';
import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/expertise/data/cache/_cache.dart';
import 'package:portrai/src/feature/expertise/data/mapper/_mapper.dart';
import 'package:portrai/src/feature/expertise/domain/_domain.dart';

@register
class CacheExpertiseRepositoryImpl implements ExpertiseRepository {
  CacheExpertiseRepositoryImpl(
    this._expertiseCache,
    this._mapper,
    this._appLocale,
  );

  final ExpertiseCache _expertiseCache;
  final ExpertiseMapper _mapper;
  final AppLocale _appLocale;

  @override
  Future<void> cacheExpertise(ExpertiseEntity expert) async {
    try {
      // Mapper already includes current locale
      return await _expertiseCache.put(_mapper.from(expert));
    } on DBNotInitialisedException catch (e, stackTrace) {
      throw ExpertiseCacheException(
        cause: 'Database not initialized: $e',
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw ExpertiseCacheException(
        cause: 'Unexpected error while caching expertise: $e',
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<ExpertiseEntity>> getAllExpertise() async {
    try {
      final currentLocale = _appLocale.languageCode;

      final expertiseList = await _expertiseCache.query(
        conditions: {'locale': currentLocale},
      );

      if (expertiseList.isEmpty) {
        throw const ExpertiseNotFoundException(
          cause: 'No expertise found in cache for current locale',
        );
      }

      return expertiseList.map(_mapper.to).toList();
    } on ExpertiseNotFoundException {
      rethrow;
    } on DBNotInitialisedException catch (e, stackTrace) {
      throw ExpertiseCacheException(
        cause: 'Database not initialized: $e',
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw ExpertiseNotFoundException(
        cause: 'Unexpected error while retrieving expertise: $e',
        stackTrace: stackTrace,
      );
    }
  }
}
