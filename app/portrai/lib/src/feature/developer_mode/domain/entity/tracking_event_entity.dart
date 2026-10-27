import 'package:equatable/equatable.dart';

/// A tracking event sent during the current app session.
class TrackingEventEntity extends Equatable {
  const TrackingEventEntity({
    required this.id,
    required this.sentAt,
    required this.name,
    required this.area,
    required this.parameters,
    this.actionType,
  });

  /// Identifies the event within the session.
  final String id;
  final DateTime sentAt;
  final String name;
  final String area;

  /// Type of the event's action, such as `click`; `null` when it has none.
  final String? actionType;

  /// The parameters sent with the event, in the order they were sent.
  final Map<String, String> parameters;

  @override
  List<Object?> get props => [id, sentAt, name, area, actionType, parameters];

  @override
  String toString() => 'TrackingEventEntity($id, $name, $area)';
}
