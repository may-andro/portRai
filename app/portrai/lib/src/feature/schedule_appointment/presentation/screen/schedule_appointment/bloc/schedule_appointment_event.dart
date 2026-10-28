import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
sealed class ScheduleAppointmentEvent extends Equatable {
  const ScheduleAppointmentEvent();

  @override
  List<Object?> get props => [];
}

final class LoadAppointmentSlotsEvent extends ScheduleAppointmentEvent {
  const LoadAppointmentSlotsEvent();
}

final class AppointmentSlotsRetryClickEvent extends ScheduleAppointmentEvent {
  const AppointmentSlotsRetryClickEvent();
}

final class AppointmentDayClickEvent extends ScheduleAppointmentEvent {
  const AppointmentDayClickEvent({required this.label, required this.day});

  /// The tapped element, such as a chip.
  final String label;
  final DateTime day;

  @override
  List<Object?> get props => [label, day];
}

final class AppointmentSlotClickEvent extends ScheduleAppointmentEvent {
  const AppointmentSlotClickEvent({required this.label, required this.slot});

  /// The tapped element, such as a chip.
  final String label;
  final DateTime slot;

  @override
  List<Object?> get props => [label, slot];
}

final class PrivacyPolicyClickEvent extends ScheduleAppointmentEvent {
  const PrivacyPolicyClickEvent(this.label);

  /// The tapped element, such as a link.
  final String label;

  @override
  List<Object?> get props => [label];
}

final class SendAppointmentRequestClickEvent extends ScheduleAppointmentEvent {
  const SendAppointmentRequestClickEvent({
    required this.label,
    required this.name,
    required this.email,
    required this.topic,
    required this.message,
    required this.hasAcceptedPrivacyPolicy,
  });

  /// The tapped element, such as a button.
  final String label;
  final String name;
  final String email;
  final String topic;
  final String message;
  final bool hasAcceptedPrivacyPolicy;

  @override
  List<Object?> get props => [
    label,
    name,
    email,
    topic,
    message,
    hasAcceptedPrivacyPolicy,
  ];

  /// Bloc events can end up in logs, so this never prints the visitor's
  /// details.
  @override
  String toString() => 'SendAppointmentRequestClickEvent';
}

// Tracking Events
final class ScreenVisibleEvent extends ScheduleAppointmentEvent {
  const ScreenVisibleEvent();
}
