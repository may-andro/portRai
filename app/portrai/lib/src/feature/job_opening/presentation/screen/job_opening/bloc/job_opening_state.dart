import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:portrai/src/feature/job_opening/domain/_domain.dart';
import 'package:use_case/use_case.dart';

enum JobOpeningStatus { loading, loaded, failed }

@immutable
class JobOpeningState extends Equatable {
  const JobOpeningState({
    this.id = '',
    this.status = JobOpeningStatus.loading,
    this.jobOpening,
    this.loadFailure,
    this.applyFailure,
  });

  final String id;
  final JobOpeningStatus status;
  final JobOpeningEntity? jobOpening;

  /// Why the opening could not be loaded, shown in place of it.
  final Failure? loadFailure;

  /// Why the job page could not be opened. Shown once.
  final Failure? applyFailure;

  JobOpeningState copyWith({
    String? id,
    JobOpeningStatus? status,
    JobOpeningEntity? jobOpening,
    Failure? loadFailure,
    bool clearLoadFailure = false,
    Failure? applyFailure,
    bool clearApplyFailure = false,
  }) {
    return JobOpeningState(
      id: id ?? this.id,
      status: status ?? this.status,
      jobOpening: jobOpening ?? this.jobOpening,
      loadFailure: clearLoadFailure ? null : loadFailure ?? this.loadFailure,
      applyFailure: clearApplyFailure
          ? null
          : applyFailure ?? this.applyFailure,
    );
  }

  @override
  List<Object?> get props => [
    id,
    status,
    jobOpening,
    loadFailure,
    applyFailure,
  ];
}
