import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:portrai/src/feature/schedule_appointment/domain/_domain.dart';

@immutable
sealed class AppointmentRequestsEvent extends Equatable {
  const AppointmentRequestsEvent();

  @override
  List<Object?> get props => [];
}

final class AppointmentRequestsStartedEvent extends AppointmentRequestsEvent {
  const AppointmentRequestsStartedEvent();
}

final class AppointmentRequestsRetryClickEvent
    extends AppointmentRequestsEvent {
  const AppointmentRequestsRetryClickEvent();
}

/// The owner confirmed [decision] for the request [requestId].
final class AppointmentRequestDecisionClickEvent
    extends AppointmentRequestsEvent {
  const AppointmentRequestDecisionClickEvent({
    required this.requestId,
    required this.decision,
  });

  final String requestId;
  final AppointmentDecision decision;

  @override
  List<Object?> get props => [requestId, decision];
}
