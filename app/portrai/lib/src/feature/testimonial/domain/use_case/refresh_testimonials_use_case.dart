import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/testimonial/domain/exception/_exception.dart';
import 'package:portrai/src/feature/testimonial/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

sealed class RefreshTestimonialsFailure extends BasicFailure {
  const RefreshTestimonialsFailure({super.cause});
}

class RefreshTestimonialsNetworkFailure extends RefreshTestimonialsFailure {
  const RefreshTestimonialsNetworkFailure({super.cause});
}

class RefreshTestimonialsDataFailure extends RefreshTestimonialsFailure {
  const RefreshTestimonialsDataFailure({super.cause});
}

class RefreshTestimonialsUnknownFailure extends RefreshTestimonialsFailure {
  const RefreshTestimonialsUnknownFailure({super.cause});
}

/// Replaces the cached testimonials of the current locale with the latest
/// ones. The cached testimonials stay when the latest ones cannot be loaded.
@register
class RefreshTestimonialsUseCase
    extends BaseNoParamUseCase<void, RefreshTestimonialsFailure> {
  RefreshTestimonialsUseCase(this._repository);

  final TestimonialRepository _repository;

  @protected
  @override
  Future<Either<RefreshTestimonialsFailure, void>> execute() async {
    await _repository.refreshTestimonials();
    return const Right(null);
  }

  @protected
  @override
  RefreshTestimonialsFailure mapErrorToFailure(Object e, StackTrace st) {
    return switch (e) {
      TestimonialNetworkException() || TestimonialUnauthorizedException() =>
        RefreshTestimonialsNetworkFailure(cause: e),
      TestimonialNotFoundException() ||
      TestimonialParsingException() ||
      TestimonialCacheException() => RefreshTestimonialsDataFailure(cause: e),
      _ => RefreshTestimonialsUnknownFailure(cause: e),
    };
  }
}
