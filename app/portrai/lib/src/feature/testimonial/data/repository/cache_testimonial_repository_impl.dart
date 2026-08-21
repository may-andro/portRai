import 'package:cache/cache.dart';
import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/testimonial/data/cache/_cache.dart';
import 'package:portrai/src/feature/testimonial/data/mapper/_mapper.dart';
import 'package:portrai/src/feature/testimonial/domain/_domain.dart';

@register
class CacheTestimonialRepositoryImpl implements TestimonialRepository {
  CacheTestimonialRepositoryImpl(
    this._testimonialCache,
    this._mapper,
    this._appLocale,
  );

  final TestimonialCache _testimonialCache;
  final TestimonialMapper _mapper;
  final AppLocale _appLocale;

  @override
  Future<void> cacheTestimonial(TestimonialEntity testimonial) async {
    try {
      return await _testimonialCache.put(_mapper.from(testimonial));
    } on DBNotInitialisedException catch (e, stackTrace) {
      throw TestimonialCacheException(
        cause: 'Database not initialized: $e',
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw TestimonialCacheException(
        cause: 'Unexpected error while caching testimonial: $e',
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<TestimonialEntity> getTestimonial(String id) async {
    try {
      if (id.trim().isEmpty) {
        throw const TestimonialNotFoundException(
          cause: 'Testimonial ID cannot be empty',
        );
      }

      final currentLocale = _appLocale.languageCode;

      final testimonial = await _testimonialCache.get(
        conditions: {'id': id, 'locale': currentLocale},
      );

      if (testimonial == null) {
        throw TestimonialNotFoundException(
          cause:
              'Testimonial with id "$id" not found in cache for current locale',
        );
      }

      return _mapper.to(testimonial);
    } on TestimonialNotFoundException {
      rethrow;
    } on DBNotInitialisedException catch (e, stackTrace) {
      throw TestimonialCacheException(
        cause: 'Database not initialized: $e',
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw TestimonialNotFoundException(
        cause: 'Unexpected error while retrieving testimonial: $e',
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<TestimonialEntity>> getTestimonials() async {
    try {
      final currentLocale = _appLocale.languageCode;

      final testimonials = await _testimonialCache.query(
        conditions: {'locale': currentLocale},
      );

      if (testimonials.isEmpty) {
        throw const TestimonialNotFoundException(
          cause: 'No testimonials found in cache for current locale',
        );
      }

      return testimonials.map(_mapper.to).toList();
    } on TestimonialNotFoundException {
      rethrow;
    } on DBNotInitialisedException catch (e, stackTrace) {
      throw TestimonialCacheException(
        cause: 'Database not initialized: $e',
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw TestimonialNotFoundException(
        cause: 'Unexpected error while retrieving testimonials: $e',
        stackTrace: stackTrace,
      );
    }
  }
}
