import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/schedule_appointment/domain/_domain.dart';
import 'package:use_case/use_case.dart';

class MockGetAppointmentSlotsUseCase extends Mock
    implements GetAppointmentSlotsUseCase {}

extension MockGetAppointmentSlotsUseCaseStub on MockGetAppointmentSlotsUseCase {
  /// Stubs `call()` to return [result].
  void stubCall(
    Either<GetAppointmentSlotsFailure, AppointmentSlotsEntity> result,
  ) {
    when(() => this()).thenAnswer((_) => result);
  }
}
