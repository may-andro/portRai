import 'package:portrai/src/feature/call_booking/domain/entity/_entity.dart';

abstract interface class CallBookingRepository {
  Future<CallSlotsEntity> getCallSlots();

  /// Books the slot of [request] and returns the request's ID.
  Future<String> requestCall(CallRequestEntity request);
}
