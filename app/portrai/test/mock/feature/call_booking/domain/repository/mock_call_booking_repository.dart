import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/call_booking/domain/_domain.dart';

class MockCallBookingRepository extends Mock implements CallBookingRepository {}

extension MockCallBookingRepositoryStub on MockCallBookingRepository {
  void stubGetCallSlots(CallSlotsEntity callSlots) {
    when(getCallSlots).thenAnswer((_) async => callSlots);
  }

  void stubGetCallSlotsThrows(Object error) {
    when(getCallSlots).thenThrow(error);
  }

  void stubRequestCall(String requestId) {
    when(() => requestCall(any())).thenAnswer((_) async => requestId);
  }

  void stubRequestCallThrows(Object error) {
    when(() => requestCall(any())).thenThrow(error);
  }
}
