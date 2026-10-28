import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/schedule_appointment/domain/_domain.dart';
import 'package:use_case/use_case.dart';

class MockRequestAppointmentUseCase extends Mock
    implements RequestAppointmentUseCase {}

extension MockRequestAppointmentUseCaseStub on MockRequestAppointmentUseCase {
  /// Stubs `call(param)` to return [result] for any [RequestAppointmentParam].
  void stubCall(Either<RequestAppointmentFailure, String> result) {
    when(() => this(any())).thenAnswer((_) => result);
  }
}
