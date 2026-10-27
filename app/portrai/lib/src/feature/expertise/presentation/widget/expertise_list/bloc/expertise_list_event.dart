import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
sealed class ExpertiseListEvent extends Equatable {
  const ExpertiseListEvent();

  @override
  List<Object?> get props => [];
}

final class ExpertiseClickEvent extends ExpertiseListEvent {
  const ExpertiseClickEvent(this.expertiseTitle);

  final String expertiseTitle;

  @override
  List<Object?> get props => [expertiseTitle];
}
