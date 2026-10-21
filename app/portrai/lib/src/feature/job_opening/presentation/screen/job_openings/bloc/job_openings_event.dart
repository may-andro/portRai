import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
sealed class JobOpeningsEvent extends Equatable {
  const JobOpeningsEvent();

  @override
  List<Object?> get props => [];
}

final class JobOpeningsStartedEvent extends JobOpeningsEvent {
  const JobOpeningsStartedEvent();
}

final class JobOpeningsRetryClickEvent extends JobOpeningsEvent {
  const JobOpeningsRetryClickEvent();
}

final class JobOpeningClickEvent extends JobOpeningsEvent {
  const JobOpeningClickEvent();
}

final class JobSearchToggleClickEvent extends JobOpeningsEvent {
  const JobSearchToggleClickEvent({required this.isEnabled});

  final bool isEnabled;

  @override
  List<Object?> get props => [isEnabled];
}

final class SignOutClickEvent extends JobOpeningsEvent {
  const SignOutClickEvent();
}
