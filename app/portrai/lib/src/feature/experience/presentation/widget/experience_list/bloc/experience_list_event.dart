import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
sealed class ExperienceListEvent extends Equatable {
  const ExperienceListEvent();

  @override
  List<Object?> get props => [];
}

final class ExperienceClickEvent extends ExperienceListEvent {
  const ExperienceClickEvent({required this.label, required this.experienceId});

  /// The tapped element, such as a button or card.
  final String label;

  /// ID of the experience that opens.
  final String experienceId;

  @override
  List<Object?> get props => [label, experienceId];
}
