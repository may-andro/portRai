import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/schedule_appointment/domain/_domain.dart';
import 'package:use_case/use_case.dart';

class MockIsScheduleAppointmentAvailableUseCase extends Mock
    implements IsScheduleAppointmentAvailableUseCase {}

extension MockIsScheduleAppointmentAvailableUseCaseStub
    on MockIsScheduleAppointmentAvailableUseCase {
  void stubCall(bool isAvailable) {
    when(() => this()).thenAnswer((_) => Right(isAvailable));
  }
}
