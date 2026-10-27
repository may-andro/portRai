import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
sealed class ExpertiseOrbitEvent extends Equatable {
  const ExpertiseOrbitEvent();

  @override
  List<Object?> get props => [];
}

final class ExpertiseOrbitClickEvent extends ExpertiseOrbitEvent {
  const ExpertiseOrbitClickEvent({
    required this.label,
    required this.expertiseTitle,
  });

  /// The tapped element, such as a button or card.
  final String label;

  /// Title of the expertise that opens.
  final String expertiseTitle;

  @override
  List<Object?> get props => [label, expertiseTitle];
}
