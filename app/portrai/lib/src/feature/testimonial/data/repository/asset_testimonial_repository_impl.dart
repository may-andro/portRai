import 'dart:convert';

import 'package:core/core.dart';
import 'package:error_reporter/error_reporter.dart';
import 'package:flutter/services.dart';
import 'package:log_reporter/log_reporter.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/asset_source/asset_source.dart';
import 'package:portrai/src/feature/testimonial/data/mapper/_mapper.dart';
import 'package:portrai/src/feature/testimonial/data/model/_model.dart';
import 'package:portrai/src/feature/testimonial/data/repository/cache_testimonial_repository_impl.dart';
import 'package:portrai/src/feature/testimonial/domain/_domain.dart';

@register
class AssetTestimonialRepositoryImpl implements TestimonialRepository {
  AssetTestimonialRepositoryImpl(
    this._appLocale,
    @Inject(CacheTestimonialRepositoryImpl) this._cacheDelegateRepository,
    this._mapper,
    this._logReporter,
    this._errorReporter,
    this._getAssetSourceUseCase,
  );

  final AppLocale _appLocale;
  final TestimonialRepository _cacheDelegateRepository;
  final TestimonialMapper _mapper;
  final LogReporter _logReporter;
  final ErrorReporter _errorReporter;
  final GetAssetSourceUseCase _getAssetSourceUseCase;
  static const _tag = 'AssetTestimonialRepositoryImpl';

  @override
  Future<void> cacheTestimonials(List<TestimonialEntity> testimonials) {
    return _cacheDelegateRepository.cacheTestimonials(testimonials);
  }

  @override
  Future<TestimonialEntity> getTestimonial(String id) async {
    final source = (await _getAssetSourceUseCase()).right;
    if (source.isTemplate) {
      final testimonials = await _loadTestimonialsFromAssets(source);
      return testimonials.firstWhereOrNull((test) => test.id == id) ??
          (throw TestimonialNotFoundException(
            cause: 'Testimonial with id "$id" not found in assets',
          ));
    }

    try {
      return await _cacheDelegateRepository.getTestimonial(id);
    } on TestimonialNotFoundException {
      _logReporter.debug(
        'Testimonial $id not found in cache, loading from assets',
        tag: _tag,
      );

      final testimonials = await _loadTestimonialsFromAssets(source);

      await _cacheTestimonialsSafely(testimonials);

      final testimonial = testimonials.firstWhereOrNull(
        (test) => test.id == id,
      );

      if (testimonial == null) {
        throw TestimonialNotFoundException(
          cause: 'Testimonial with id "$id" not found in assets',
        );
      }

      return testimonial;
    } on TestimonialCacheException catch (e, stackTrace) {
      _logReporter.error(
        'Cache error while getting testimonial "$id": ${e.cause}',
        tag: _tag,
        stacktrace: stackTrace,
      );

      final testimonials = await _loadTestimonialsFromAssets(source);

      final testimonial = testimonials.firstWhereOrNull(
        (test) => test.id == id,
      );

      if (testimonial == null) {
        throw TestimonialNotFoundException(
          cause: 'Testimonial with id "$id" not found in assets',
        );
      }

      return testimonial;
    }
  }

  @override
  Future<List<TestimonialEntity>> getTestimonials() async {
    final source = (await _getAssetSourceUseCase()).right;
    if (source.isTemplate) return await _loadTestimonialsFromAssets(source);

    try {
      final cachedTestimonials = await _cacheDelegateRepository
          .getTestimonials();
      if (cachedTestimonials.isNotEmpty) {
        return cachedTestimonials;
      }
    } on TestimonialNotFoundException catch (_) {
    } on TestimonialCacheException catch (e, stackTrace) {
      _logReporter.error(
        'Cache error while getting testimonials: ${e.cause}',
        tag: _tag,
        stacktrace: stackTrace,
      );
    }

    final testimonials = await _loadTestimonialsFromAssets(source);

    await _cacheTestimonialsSafely(testimonials);

    return testimonials;
  }

  Future<List<TestimonialEntity>> _loadTestimonialsFromAssets(
    AssetSource source,
  ) async {
    try {
      final locale = _appLocale.languageCode;
      final jsonString = await rootBundle.loadString(
        source.assetPath('testimonials'),
      );
      final localeTestimonialJson =
          (jsonDecode(jsonString) as Map<String, dynamic>)[locale]
              as Map<String, dynamic>;

      final testimonialJson =
          localeTestimonialJson['testimonials'] as List<dynamic>;

      return testimonialJson.map((json) {
        final testimonialMap = json as Map<String, dynamic>;

        testimonialMap['locale'] = locale;

        return _mapper.to(TestimonialModel.fromJson(testimonialMap));
      }).toList();
    } catch (e, st) {
      throw TestimonialParsingException(
        cause: 'Failed to load testimonials from assets: $e',
        stackTrace: st,
      );
    }
  }

  Future<void> _cacheTestimonialsSafely(
    List<TestimonialEntity> testimonials,
  ) async {
    try {
      await cacheTestimonials(testimonials);
    } on TestimonialCacheException catch (exception, stackTrace) {
      // Loading still succeeds without the cache, so the failure is reported
      // instead of thrown.
      await _errorReporter.reportError(
        exception: exception,
        stackTrace: stackTrace,
        tag: _tag,
      );
    }
  }
}
