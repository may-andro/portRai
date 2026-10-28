import 'package:equatable/equatable.dart';

/// What a notification is about, from the `kind` its sender sets.
enum PushMessageKind {
  /// New job openings for the signed-in user.
  jobOpenings,

  /// A visitor asked the signed-in owner for an appointment.
  appointmentRequest,

  /// The portfolio content changed.
  portfolioUpdate,

  /// A kind this version of the app does not know.
  unknown,
}

class PushMessageEntity extends Equatable {
  const PushMessageEntity({required this.kind, this.title, this.body});

  final PushMessageKind kind;
  final String? title;
  final String? body;

  @override
  List<Object?> get props => [kind, title, body];
}
