import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:portrai/src/feature/job_opening/presentation/screen/job_openings/bloc/job_openings_state.dart';

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

final class JobOpeningsSearchChangedEvent extends JobOpeningsEvent {
  const JobOpeningsSearchChangedEvent(this.searchQuery);

  final String searchQuery;

  @override
  List<Object?> get props => [searchQuery];
}

/// Turns [filter] on when it is off, and off when it is on.
final class JobOpeningsFilterClickEvent extends JobOpeningsEvent {
  const JobOpeningsFilterClickEvent(this.filter);

  final JobOpeningsFilter filter;

  @override
  List<Object?> get props => [filter];
}

/// Clears the search and every filter.
final class JobOpeningsClearFiltersClickEvent extends JobOpeningsEvent {
  const JobOpeningsClearFiltersClickEvent();
}

final class SignOutClickEvent extends JobOpeningsEvent {
  const SignOutClickEvent();
}
