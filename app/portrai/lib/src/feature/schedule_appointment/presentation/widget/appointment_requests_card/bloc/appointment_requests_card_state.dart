import 'package:equatable/equatable.dart';

/// The card shows fixed content, so its bloc only handles the tap and keeps
/// no state of its own.
final class AppointmentRequestsCardState extends Equatable {
  const AppointmentRequestsCardState();

  @override
  List<Object?> get props => [];
}
