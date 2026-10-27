import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
sealed class PersonalSummaryEvent extends Equatable {
  const PersonalSummaryEvent();

  @override
  List<Object?> get props => [];
}

final class ViewProfileClickEvent extends PersonalSummaryEvent {
  const ViewProfileClickEvent(this.label);

  /// The tapped element, such as a button or card.
  final String label;

  @override
  List<Object?> get props => [label];
}
