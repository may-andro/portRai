import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/testimonial/domain/entity/_entity.dart';
import 'package:portrai/src/feature/testimonial/domain/exception/_exception.dart';
import 'package:portrai/src/feature/testimonial/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

sealed class GetTestimonialsFailure extends BasicFailure {
  const GetTestimonialsFailure({super.cause});
}

@Localizable('errorTestimonialsNotFound')
class TestimonialsNotFoundFailure extends GetTestimonialsFailure {
  const TestimonialsNotFoundFailure({super.cause});
}

@Localizable('errorTestimonialsNetwork')
class TestimonialsNetworkFailure extends GetTestimonialsFailure {
  const TestimonialsNetworkFailure({super.cause});
}

@Localizable('errorTestimonialsData')
class TestimonialsDataFailure extends GetTestimonialsFailure {
  const TestimonialsDataFailure({super.cause});
}

@Localizable('errorTestimonialsUnauthorized')
class TestimonialsUnauthorizedFailure extends GetTestimonialsFailure {
  const TestimonialsUnauthorizedFailure({super.cause});
}

@Localizable('errorTestimonialsUnknown')
class TestimonialsUnknownFailure extends GetTestimonialsFailure {
  const TestimonialsUnknownFailure({super.cause});
}

@register
class GetTestimonialsUseCase
    extends
        BaseNoParamUseCase<List<TestimonialEntity>, GetTestimonialsFailure> {
  GetTestimonialsUseCase(this._repository);

  final TestimonialRepository _repository;

  @protected
  @override
  Future<Either<GetTestimonialsFailure, List<TestimonialEntity>>>
  execute() async {
    final testimonials = await _repository.getTestimonials();
    return Right(testimonials);
  }

  @protected
  @override
  GetTestimonialsFailure mapErrorToFailure(Object e, StackTrace st) {
    return switch (e) {
      TestimonialNotFoundException() => TestimonialsNotFoundFailure(cause: e),
      TestimonialNetworkException() => TestimonialsNetworkFailure(cause: e),
      TestimonialParsingException() => TestimonialsDataFailure(cause: e),
      TestimonialUnauthorizedException() => TestimonialsUnauthorizedFailure(
        cause: e,
      ),
      TestimonialCacheException() => TestimonialsDataFailure(cause: e),
      _ => TestimonialsUnknownFailure(cause: e),
    };
  }
}
