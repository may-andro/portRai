import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/testimonial/testimonial.dart';
import 'package:use_case/use_case.dart';

class MockRefreshTestimonialsUseCase extends Mock
    implements RefreshTestimonialsUseCase {}

extension MockRefreshTestimonialsUseCaseStub on MockRefreshTestimonialsUseCase {
  void stubCall(Either<RefreshTestimonialsFailure, void> result) {
    when(() => this()).thenAnswer((_) => result);
  }
}
