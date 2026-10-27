import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
sealed class JobOpeningsCardEvent extends Equatable {
  const JobOpeningsCardEvent();

  @override
  List<Object?> get props => [];
}

final class JobOpeningsCardClickEvent extends JobOpeningsCardEvent {
  const JobOpeningsCardClickEvent(this.label);

  /// The tapped element, such as a button or card.
  final String label;

  @override
  List<Object?> get props => [label];
}
