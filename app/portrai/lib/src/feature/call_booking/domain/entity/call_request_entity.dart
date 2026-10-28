import 'package:equatable/equatable.dart';

/// A visitor's request for a call in one slot.
class CallRequestEntity extends Equatable {
  const CallRequestEntity({
    required this.slotStart,
    required this.name,
    required this.email,
    required this.topic,
    required this.message,
  });

  final DateTime slotStart;
  final String name;
  final String email;
  final String topic;

  /// Empty when the visitor wrote none.
  final String message;

  @override
  List<Object?> get props => [slotStart, name, email, topic, message];

  /// Requests can end up in logs, so this never prints the visitor's details.
  @override
  String toString() => 'CallRequestEntity(slotStart: $slotStart)';
}
