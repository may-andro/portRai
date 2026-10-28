import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:portrai/src/feature/schedule_appointment/domain/_domain.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/screen/appointment_requests/bloc/appointment_requests_state.dart';

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

final class AppointmentRequestsSearchChangedEvent
    extends AppointmentRequestsEvent {
  const AppointmentRequestsSearchChangedEvent(this.searchQuery);

  final String searchQuery;

  @override
  List<Object?> get props => [searchQuery];
}

/// Turns [filter] on, or off when it is on.
final class AppointmentRequestsFilterClickEvent
    extends AppointmentRequestsEvent {
  const AppointmentRequestsFilterClickEvent(this.filter);

  final AppointmentRequestsFilter filter;

  @override
  List<Object?> get props => [filter];
}

/// Shows the week that starts on [weekStart] in the timeline.
final class AppointmentRequestsWeekClickEvent extends AppointmentRequestsEvent {
  const AppointmentRequestsWeekClickEvent({
    required this.label,
    required this.weekStart,
  });

  /// The tapped element, such as `previous_week`.
  final String label;

  /// The local midnight of the week's Monday.
  final DateTime weekStart;

  @override
  List<Object?> get props => [label, weekStart];
}

/// Narrows the list to [day], or shows every day again when it is picked.
final class AppointmentRequestsDayClickEvent extends AppointmentRequestsEvent {
  const AppointmentRequestsDayClickEvent(this.day);

  /// The local midnight of the day.
  final DateTime day;

  @override
  List<Object?> get props => [day];
}

/// Clears the search, the filter and the picked day.
final class AppointmentRequestsClearFiltersClickEvent
    extends AppointmentRequestsEvent {
  const AppointmentRequestsClearFiltersClickEvent();
}
