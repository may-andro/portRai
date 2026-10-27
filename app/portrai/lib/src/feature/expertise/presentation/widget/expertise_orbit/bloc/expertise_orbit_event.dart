import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
sealed class ExpertiseOrbitEvent extends Equatable {
  const ExpertiseOrbitEvent();

  @override
  List<Object?> get props => [];
}

final class ExpertiseOrbitClickEvent extends ExpertiseOrbitEvent {
  const ExpertiseOrbitClickEvent(this.expertiseTitle);

  final String expertiseTitle;

  @override
  List<Object?> get props => [expertiseTitle];
}
