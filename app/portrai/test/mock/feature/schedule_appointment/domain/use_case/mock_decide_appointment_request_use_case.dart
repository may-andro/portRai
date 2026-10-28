import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/schedule_appointment/domain/_domain.dart';
import 'package:use_case/use_case.dart';

class MockDecideAppointmentRequestUseCase extends Mock
    implements DecideAppointmentRequestUseCase {}

extension MockDecideAppointmentRequestUseCaseStub
    on MockDecideAppointmentRequestUseCase {
  /// Stubs `call(param)` to return [result].
  void stubCall(Either<DecideAppointmentRequestFailure, void> result) {
    when(() => this(any())).thenAnswer((_) => result);
  }
}
