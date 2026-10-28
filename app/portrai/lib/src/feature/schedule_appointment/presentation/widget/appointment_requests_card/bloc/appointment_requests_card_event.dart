import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
sealed class AppointmentRequestsCardEvent extends Equatable {
  const AppointmentRequestsCardEvent();

  @override
  List<Object?> get props => [];
}

final class AppointmentRequestsCardClickEvent
    extends AppointmentRequestsCardEvent {
  const AppointmentRequestsCardClickEvent(this.label);

  /// The tapped element, such as a button or card.
  final String label;

  @override
  List<Object?> get props => [label];
}
