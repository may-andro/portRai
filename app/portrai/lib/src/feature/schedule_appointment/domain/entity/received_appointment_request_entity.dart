import 'package:equatable/equatable.dart';

enum AppointmentRequestStatus { requested, accepted, declined }

/// The owner's answer to a request.
enum AppointmentDecision {
  accept(AppointmentRequestStatus.accepted),
  decline(AppointmentRequestStatus.declined);

  const AppointmentDecision(this.status);

  /// The status the request has after this answer.
  final AppointmentRequestStatus status;
}

/// A visitor's request as the owner receives it.
class ReceivedAppointmentRequestEntity extends Equatable {
  const ReceivedAppointmentRequestEntity({
    required this.id,
    required this.slotStart,
    required this.slotEnd,
    required this.name,
    required this.email,
    required this.topic,
    required this.message,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final DateTime slotStart;
  final DateTime slotEnd;
  final String name;
  final String email;
  final String topic;

  /// Empty when the visitor wrote none.
  final String message;
  final AppointmentRequestStatus status;
  final DateTime createdAt;

  /// Whether the owner can still accept or decline the request at [now]: it
  /// is unanswered and its slot has not started.
  bool isAnswerableAt(DateTime now) =>
      status == AppointmentRequestStatus.requested && slotStart.isAfter(now);

  ReceivedAppointmentRequestEntity copyWith({
    AppointmentRequestStatus? status,
  }) {
    return ReceivedAppointmentRequestEntity(
      id: id,
      slotStart: slotStart,
      slotEnd: slotEnd,
      name: name,
      email: email,
      topic: topic,
      message: message,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    slotStart,
    slotEnd,
    name,
    email,
    topic,
    message,
    status,
    createdAt,
  ];

  /// Requests can end up in logs, so this never prints the visitor's details.
  @override
  String toString() =>
      'ReceivedAppointmentRequestEntity(id: $id, slotStart: $slotStart, '
      'status: ${status.name})';
}
