import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter/services.dart';
import 'package:log_reporter/log_reporter.dart';
import 'package:module_injector/module_injector.dart';
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
  );

  final AppLocale _appLocale;
  final TestimonialRepository _cacheDelegateRepository;
  final TestimonialMapper _mapper;
  final LogReporter _logReporter;

  @override
  Future<void> cacheTestimonial(TestimonialEntity testimonial) {
    return _cacheDelegateRepository.cacheTestimonial(testimonial);
  }

  @override
  Future<TestimonialEntity> getTestimonial(String id) async {
    try {
      return await _cacheDelegateRepository.getTestimonial(id);
    } on TestimonialNotFoundException catch (_) {
      // Testimonial not found in cache, load from assets
      final testimonials = await _loadTestimonialsFromAssets();

      // Try to cache them, but don't fail if caching fails
      await _cacheTestimonialsSafely(testimonials);

      // Find the requested testimonial
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
      // Cache has data corruption or DB issues, try loading from assets directly
      _logReporter.error(
        'Cache error while getting testimonial "$id": ${e.cause}',
        stacktrace: stackTrace,
      );

      final testimonials = await _loadTestimonialsFromAssets();

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
    try {
      final cachedTestimonials = await _cacheDelegateRepository
          .getTestimonials();
      if (cachedTestimonials.isNotEmpty) {
        return cachedTestimonials;
      }
    } on TestimonialNotFoundException catch (_) {
    } on TestimonialCacheException catch (e, stackTrace) {
      // Cache has issues (DB not initialized, corruption, etc.)
      _logReporter.error(
        'Cache error while getting testimonials: ${e.cause}',
        stacktrace: stackTrace,
      );
      // Fall through to load from assets
    }

    // Cache is empty, expired, or has issues - fetch from assets
    final testimonials = await _loadTestimonialsFromAssets();

    // Try to cache them, but don't fail if caching fails
    await _cacheTestimonialsSafely(testimonials);

    return testimonials;
  }

  /// Loads testimonials from assets file based on app locale
  Future<List<TestimonialEntity>> _loadTestimonialsFromAssets() async {
    try {
      final locale = _appLocale.languageCode;
      // Load JSON from assets file
      final jsonString = await rootBundle.loadString(
        'assets/dashboard/testimonials.json',
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

  /// Attempts to cache testimonials, but doesn't throw if caching fails
  Future<void> _cacheTestimonialsSafely(
    List<TestimonialEntity> testimonials,
  ) async {
    try {
      for (final testimonial in testimonials) {
        await cacheTestimonial(testimonial);
      }
    } catch (_) {
      _logReporter.error(
        'Failed to cache testimonials from assets, continuing without caching.',
      );
    }
  }
}
