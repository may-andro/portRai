import 'package:portrai/src/feature/schedule_appointment/domain/entity/_entity.dart';

/// The requests visitors sent to the owner [userId].
abstract interface class AppointmentRequestRepository {
  /// The requests in no particular order.
  Future<List<ReceivedAppointmentRequestEntity>> getAppointmentRequests(
    String userId,
  );

  /// Answers the unanswered request [id], which sends the visitor an email.
  Future<void> decideAppointmentRequest({
    required String userId,
    required String id,
    required AppointmentDecision decision,
  });
}
