import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
sealed class ScheduleAppointmentEntryEvent extends Equatable {
  const ScheduleAppointmentEntryEvent();

  @override
  List<Object?> get props => [];
}

final class LoadScheduleAppointmentEntryEvent
    extends ScheduleAppointmentEntryEvent {
  const LoadScheduleAppointmentEntryEvent();
}

final class ScheduleAppointmentClickEvent
    extends ScheduleAppointmentEntryEvent {
  const ScheduleAppointmentClickEvent({required this.label, this.topic});

  /// The tapped element, such as a button.
  final String label;

  /// What the appointment is about, such as a service's title, or null.
  final String? topic;

  @override
  List<Object?> get props => [label, topic];
}
