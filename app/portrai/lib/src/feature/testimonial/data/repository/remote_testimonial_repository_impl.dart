import 'package:core/core.dart';
import 'package:firebase/firebase.dart';
import 'package:log_reporter/log_reporter.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/testimonial/data/mapper/_mapper.dart';
import 'package:portrai/src/feature/testimonial/data/model/_model.dart';
import 'package:portrai/src/feature/testimonial/data/repository/cache_testimonial_repository_impl.dart';
import 'package:portrai/src/feature/testimonial/domain/_domain.dart';

@register
class RemoteTestimonialRepositoryImpl implements TestimonialRepository {
  RemoteTestimonialRepositoryImpl(
    this._firestoreController,
    this._appLocale,
    @Inject(CacheTestimonialRepositoryImpl) this._cacheDelegateRepository,
    this._mapper,
    this._logReporter,
  );

  final FbFirestoreController _firestoreController;
  final AppLocale _appLocale;
  final TestimonialRepository _cacheDelegateRepository;
  final TestimonialMapper _mapper;
  final LogReporter _logReporter;
  static const _tag = 'RemoteTestimonialRepositoryImpl';

  @override
  Future<void> cacheTestimonial(TestimonialEntity testimonial) {
    return _cacheDelegateRepository.cacheTestimonial(testimonial);
  }

  @override
  Future<TestimonialEntity> getTestimonial(String id) async {
    try {
      return await _cacheDelegateRepository.getTestimonial(id);
    } on TestimonialNotFoundException {
      _logReporter.debug(
        'Testimonial $id not found in cache, loading from remote',
        tag: _tag,
      );

      final testimonials = await _loadTestimonialsFromRemote();

      await _cacheTestimonialsSafely(testimonials);

      final testimonial = testimonials.firstWhereOrNull(
        (test) => test.id == id,
      );

      if (testimonial == null) {
        throw TestimonialNotFoundException(
          cause: 'Testimonial with id "$id" not found in remote',
        );
      }

      return testimonial;
    } on TestimonialCacheException catch (_) {
      _logReporter.error(
        'Cache error while getting testimonial, loading from remote instead.',
        tag: _tag,
      );

      final testimonials = await _loadTestimonialsFromRemote();

      final testimonial = testimonials.firstWhereOrNull(
        (test) => test.id == id,
      );

      if (testimonial == null) {
        throw TestimonialNotFoundException(
          cause: 'Testimonial with id "$id" not found in remote',
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
    } on TestimonialCacheException catch (_) {
      _logReporter.error(
        'Cache error while getting testimonials, loading from remote instead.',
        tag: _tag,
      );
    }

    final testimonials = await _loadTestimonialsFromRemote();

    await _cacheTestimonialsSafely(testimonials);

    return testimonials;
  }

  Future<List<TestimonialEntity>> _loadTestimonialsFromRemote() async {
    try {
      final locale = _appLocale.languageCode;
      final testimonialJson = await _firestoreController
          .getDocumentFromCollection('testimonials', locale);

      if (testimonialJson == null) {
        throw const TestimonialNotFoundException(
          cause: 'Testimonial document not found in Firestore',
        );
      }

      try {
        final testimonialsJson =
            testimonialJson['testimonials'] as List<dynamic>;
        final testimonials = testimonialsJson.map((json) {
          final testimonialMap = json as Map<String, dynamic>;

          testimonialMap['locale'] = locale;

          final testimonialModel = TestimonialModel.fromJson(testimonialMap);
          return _mapper.to(testimonialModel);
        }).toList();

        return testimonials;
      } catch (e, st) {
        throw TestimonialParsingException(
          cause: 'Failed to parse testimonials from Firestore: $e',
          stackTrace: st,
        );
      }
    } on TestimonialNotFoundException {
      rethrow;
    } on TestimonialParsingException {
      rethrow;
    } on FirestoreDocumentNotFoundException catch (e, st) {
      throw TestimonialNotFoundException(cause: e, stackTrace: st);
    } on FirestorePermissionDeniedException catch (e, st) {
      throw TestimonialUnauthorizedException(cause: e, stackTrace: st);
    } on FirestoreTimeoutException catch (e, st) {
      throw TestimonialNetworkException(cause: e, stackTrace: st);
    } on FirestoreInvalidDataException catch (e, st) {
      throw TestimonialParsingException(cause: e, stackTrace: st);
    } on FirestoreQuotaExceededException catch (e, st) {
      throw TestimonialNetworkException(cause: e, stackTrace: st);
    } catch (e, st) {
      throw TestimonialParsingException(
        cause: 'Unexpected error while loading testimonials: $e',
        stackTrace: st,
      );
    }
  }

  Future<void> _cacheTestimonialsSafely(
    List<TestimonialEntity> testimonials,
  ) async {
    try {
      for (final testimonial in testimonials) {
        await cacheTestimonial(testimonial);
      }
    } catch (_) {
      _logReporter.error(
        'Failed to cache testimonials from remote, continuing without caching.',
        tag: _tag,
      );
    }
  }
}
