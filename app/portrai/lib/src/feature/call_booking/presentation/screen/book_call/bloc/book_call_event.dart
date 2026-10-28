import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
sealed class BookCallEvent extends Equatable {
  const BookCallEvent();

  @override
  List<Object?> get props => [];
}

final class LoadCallSlotsEvent extends BookCallEvent {
  const LoadCallSlotsEvent();
}

final class CallSlotsRetryClickEvent extends BookCallEvent {
  const CallSlotsRetryClickEvent();
}

final class CallDayClickEvent extends BookCallEvent {
  const CallDayClickEvent({required this.label, required this.day});

  /// The tapped element, such as a chip.
  final String label;
  final DateTime day;

  @override
  List<Object?> get props => [label, day];
}

final class CallSlotClickEvent extends BookCallEvent {
  const CallSlotClickEvent({required this.label, required this.slot});

  /// The tapped element, such as a chip.
  final String label;
  final DateTime slot;

  @override
  List<Object?> get props => [label, slot];
}

final class PrivacyPolicyClickEvent extends BookCallEvent {
  const PrivacyPolicyClickEvent(this.label);

  /// The tapped element, such as a link.
  final String label;

  @override
  List<Object?> get props => [label];
}

final class SendCallRequestClickEvent extends BookCallEvent {
  const SendCallRequestClickEvent({
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
  String toString() => 'SendCallRequestClickEvent';
}

// Tracking Events
final class ScreenVisibleEvent extends BookCallEvent {
  const ScreenVisibleEvent();
}
