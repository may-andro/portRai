import 'package:json_annotation/json_annotation.dart';

part 'call_request_model.g.dart';

/// A call request as the booking function takes it.
@JsonSerializable(createFactory: false)
class CallRequestModel {
  CallRequestModel({
    required this.slotStart,
    required this.name,
    required this.email,
    required this.topic,
    required this.message,
    required this.locale,
  });

  /// An ISO 8601 string in UTC.
  final String slotStart;
  final String name;
  final String email;
  final String topic;
  final String message;

  /// The app's language, which the visitor's emails are written in.
  final String locale;

  Map<String, dynamic> toJson() => _$CallRequestModelToJson(this);

  /// Requests can end up in logs, so this never prints the visitor's details.
  @override
  String toString() => 'CallRequestModel(slotStart: $slotStart)';
}
