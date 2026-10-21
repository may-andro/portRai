import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:portrai/src/feature/job_opening/domain/_domain.dart';
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:use_case/use_case.dart';

enum JobOpeningsStatus { loading, loaded, failed }

@immutable
class JobOpeningsState extends Equatable {
  const JobOpeningsState({
    this.status = JobOpeningsStatus.loading,
    this.jobOpenings = const [],
    this.loadFailure,
    this.isJobSearchEnabled,
    this.isUpdatingJobSearch = false,
    this.isSigningOut = false,
    this.isSignedOut = false,
    this.actionFailure,
    this.profile,
  });

  final JobOpeningsStatus status;
  final List<JobOpeningEntity> jobOpenings;

  /// Why the openings could not be loaded, shown in place of the list.
  final Failure? loadFailure;

  /// Null until the setting has loaded, or when it could not be read.
  final bool? isJobSearchEnabled;
  final bool isUpdatingJobSearch;
  final bool isSigningOut;
  final bool isSignedOut;

  /// Why turning job search on or off, or signing out, failed. Shown once.
  final Failure? actionFailure;

  /// For the page footer; null until loaded or when it could not be read.
  final ProfileEntity? profile;

  JobOpeningsState copyWith({
    JobOpeningsStatus? status,
    List<JobOpeningEntity>? jobOpenings,
    Failure? loadFailure,
    bool clearLoadFailure = false,
    bool? isJobSearchEnabled,
    bool? isUpdatingJobSearch,
    bool? isSigningOut,
    bool? isSignedOut,
    Failure? actionFailure,
    bool clearActionFailure = false,
    ProfileEntity? profile,
  }) {
    return JobOpeningsState(
      status: status ?? this.status,
      jobOpenings: jobOpenings ?? this.jobOpenings,
      loadFailure: clearLoadFailure ? null : loadFailure ?? this.loadFailure,
      isJobSearchEnabled: isJobSearchEnabled ?? this.isJobSearchEnabled,
      isUpdatingJobSearch: isUpdatingJobSearch ?? this.isUpdatingJobSearch,
      isSigningOut: isSigningOut ?? this.isSigningOut,
      isSignedOut: isSignedOut ?? this.isSignedOut,
      actionFailure: clearActionFailure
          ? null
          : actionFailure ?? this.actionFailure,
      profile: profile ?? this.profile,
    );
  }

  @override
  List<Object?> get props => [
    status,
    jobOpenings,
    loadFailure,
    isJobSearchEnabled,
    isUpdatingJobSearch,
    isSigningOut,
    isSignedOut,
    actionFailure,
    profile,
  ];
}
