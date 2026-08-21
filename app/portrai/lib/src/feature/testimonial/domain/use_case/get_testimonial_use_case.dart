import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/testimonial/domain/entity/_entity.dart';
import 'package:portrai/src/feature/testimonial/domain/exception/_exception.dart';
import 'package:portrai/src/feature/testimonial/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

sealed class GetTestimonialFailure extends BasicFailure {
  const GetTestimonialFailure({super.cause});
}

@Localizable('errorTestimonialNotFound')
class TestimonialNotFoundFailure extends GetTestimonialFailure {
  const TestimonialNotFoundFailure({super.cause});
}

@Localizable('errorTestimonialNetwork')
class TestimonialNetworkFailure extends GetTestimonialFailure {
  const TestimonialNetworkFailure({super.cause});
}

@Localizable('errorTestimonialData')
class TestimonialDataFailure extends GetTestimonialFailure {
  const TestimonialDataFailure({super.cause});
}

@Localizable('errorTestimonialUnauthorized')
class TestimonialUnauthorizedFailure extends GetTestimonialFailure {
  const TestimonialUnauthorizedFailure({super.cause});
}

@Localizable('errorTestimonialUnknown')
class TestimonialUnknownFailure extends GetTestimonialFailure {
  const TestimonialUnknownFailure({super.cause});
}

@register
class GetTestimonialUseCase
    extends BaseUseCase<TestimonialEntity, String, GetTestimonialFailure> {
  GetTestimonialUseCase(this._repository);

  final TestimonialRepository _repository;

  @protected
  @override
  Future<Either<GetTestimonialFailure, TestimonialEntity>> execute(
    String input,
  ) async {
    final testimonial = await _repository.getTestimonial(input);
    return Right(testimonial);
  }

  @protected
  @override
  GetTestimonialFailure mapErrorToFailure(Object e, StackTrace st) {
    return switch (e) {
      TestimonialNotFoundException() => TestimonialNotFoundFailure(cause: e),
      TestimonialNetworkException() => TestimonialNetworkFailure(cause: e),
      TestimonialParsingException() => TestimonialDataFailure(cause: e),
      TestimonialUnauthorizedException() => TestimonialUnauthorizedFailure(
        cause: e,
      ),
      TestimonialCacheException() => TestimonialDataFailure(cause: e),
      _ => TestimonialUnknownFailure(cause: e),
    };
  }
}
