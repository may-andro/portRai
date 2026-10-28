import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/schedule_appointment/domain/_domain.dart';

class MockAppointmentRequestRepository extends Mock
    implements AppointmentRequestRepository {}

extension MockAppointmentRequestRepositoryStub
    on MockAppointmentRequestRepository {
  void stubGetAppointmentRequests(
    List<ReceivedAppointmentRequestEntity> requests,
  ) {
    when(() => getAppointmentRequests(any())).thenAnswer((_) async => requests);
  }

  void stubGetAppointmentRequestsThrows(Object error) {
    when(() => getAppointmentRequests(any())).thenThrow(error);
  }

  void stubDecideAppointmentRequest() {
    when(
      () => decideAppointmentRequest(
        userId: any(named: 'userId'),
        id: any(named: 'id'),
        decision: any(named: 'decision'),
      ),
    ).thenAnswer((_) async {});
  }

  void stubDecideAppointmentRequestThrows(Object error) {
    when(
      () => decideAppointmentRequest(
        userId: any(named: 'userId'),
        id: any(named: 'id'),
        decision: any(named: 'decision'),
      ),
    ).thenThrow(error);
  }
}
