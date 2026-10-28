import 'package:firebase/firebase.dart';
import 'package:json_annotation/json_annotation.dart';

part 'received_appointment_request_model.g.dart';

/// A `users/{uid}/call_requests/{id}` document, written by the appointment
/// function. The ID is the document ID, added when the document is read.
@JsonSerializable(createToJson: false)
class ReceivedAppointmentRequestModel {
  ReceivedAppointmentRequestModel({
    required this.id,
    required this.slotStart,
    required this.slotEnd,
    required this.name,
    required this.email,
    required this.topic,
    required this.status,
    required this.createdAt,
    this.message = '',
  });

  factory ReceivedAppointmentRequestModel.fromJson(Map<String, dynamic> json) =>
      _$ReceivedAppointmentRequestModelFromJson(json);

  final String id;
  @JsonKey(fromJson: _dateTimeFromTimestamp)
  final DateTime slotStart;
  @JsonKey(fromJson: _dateTimeFromTimestamp)
  final DateTime slotEnd;
  final String name;
  final String email;
  final String topic;
  final String message;

  /// `requested`, `accepted` or `declined`.
  final String status;
  @JsonKey(fromJson: _dateTimeFromTimestamp)
  final DateTime createdAt;

  /// Requests can end up in logs, so this never prints the visitor's details.
  @override
  String toString() =>
      'ReceivedAppointmentRequestModel(id: $id, status: $status)';

  static DateTime _dateTimeFromTimestamp(Object json) => switch (json) {
    Timestamp() => json.toDate(),
    DateTime() => json,
    _ => throw FormatException('Not a Firestore timestamp: $json'),
  };
}
