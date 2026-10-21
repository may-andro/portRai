import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
sealed class JobOpeningEvent extends Equatable {
  const JobOpeningEvent();

  @override
  List<Object?> get props => [];
}

final class JobOpeningStartedEvent extends JobOpeningEvent {
  const JobOpeningStartedEvent({required this.id});

  final String id;

  @override
  List<Object?> get props => [id];
}

final class JobOpeningRetryClickEvent extends JobOpeningEvent {
  const JobOpeningRetryClickEvent();
}

final class ApplyClickEvent extends JobOpeningEvent {
  const ApplyClickEvent();
}

final class GenerateInsightsClickEvent extends JobOpeningEvent {
  const GenerateInsightsClickEvent();
}
