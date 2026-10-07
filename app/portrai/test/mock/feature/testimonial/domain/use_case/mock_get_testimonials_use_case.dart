import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/testimonial/testimonial.dart';
import 'package:use_case/use_case.dart';

class MockGetTestimonialsUseCase extends Mock
    implements GetTestimonialsUseCase {}

extension MockGetTestimonialsUseCaseStub on MockGetTestimonialsUseCase {
  void stubCall(
    Either<GetTestimonialsFailure, List<TestimonialEntity>> result,
  ) {
    when(() => this()).thenAnswer((_) => result);
  }
}
