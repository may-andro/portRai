import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/schedule_appointment/domain/_domain.dart';
import 'package:use_case/use_case.dart';

class MockGetAppointmentRequestsUseCase extends Mock
    implements GetAppointmentRequestsUseCase {}

extension MockGetAppointmentRequestsUseCaseStub
    on MockGetAppointmentRequestsUseCase {
  /// Stubs `call()` to return [result].
  void stubCall(
    Either<
      GetAppointmentRequestsFailure,
      List<ReceivedAppointmentRequestEntity>
    >
    result,
  ) {
    when(() => this()).thenAnswer((_) => result);
  }
}
