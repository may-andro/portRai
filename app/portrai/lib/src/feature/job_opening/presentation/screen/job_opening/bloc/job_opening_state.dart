import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:portrai/src/feature/job_opening/domain/_domain.dart';
import 'package:use_case/use_case.dart';

enum JobOpeningStatus { loading, loaded, failed }

enum JobOpeningInsightsStatus { unavailable, idle, generating, ready, failed }

@immutable
class JobOpeningState extends Equatable {
  const JobOpeningState({
    this.id = '',
    this.status = JobOpeningStatus.loading,
    this.jobOpening,
    this.loadFailure,
    this.applyFailure,
    this.insightsStatus = JobOpeningInsightsStatus.unavailable,
    this.insightsController,
    this.insightsSurfaceIds = const [],
    this.insightsFailure,
    this.isTailoredCvAvailable = false,
  });

  final String id;
  final JobOpeningStatus status;
  final JobOpeningEntity? jobOpening;

  /// Why the opening could not be loaded, shown in place of it.
  final Failure? loadFailure;

  /// Why the job page could not be opened. Shown once.
  final Failure? applyFailure;

  final JobOpeningInsightsStatus insightsStatus;

  /// Renders [insightsSurfaceIds]; null until insights are generated.
  final AssistantGenuiController? insightsController;
  final List<String> insightsSurfaceIds;

  /// Why the insights could not be generated, shown in place of them.
  final Failure? insightsFailure;

  /// Whether a CV tailored for the opening can be created.
  final bool isTailoredCvAvailable;

  JobOpeningState copyWith({
    String? id,
    JobOpeningStatus? status,
    JobOpeningEntity? jobOpening,
    Failure? loadFailure,
    bool clearLoadFailure = false,
    Failure? applyFailure,
    bool clearApplyFailure = false,
    JobOpeningInsightsStatus? insightsStatus,
    AssistantGenuiController? insightsController,
    bool clearInsightsController = false,
    List<String>? insightsSurfaceIds,
    Failure? insightsFailure,
    bool clearInsightsFailure = false,
    bool? isTailoredCvAvailable,
  }) {
    return JobOpeningState(
      id: id ?? this.id,
      status: status ?? this.status,
      jobOpening: jobOpening ?? this.jobOpening,
      loadFailure: clearLoadFailure ? null : loadFailure ?? this.loadFailure,
      applyFailure: clearApplyFailure
          ? null
          : applyFailure ?? this.applyFailure,
      insightsStatus: insightsStatus ?? this.insightsStatus,
      insightsController: clearInsightsController
          ? null
          : insightsController ?? this.insightsController,
      insightsSurfaceIds: insightsSurfaceIds ?? this.insightsSurfaceIds,
      insightsFailure: clearInsightsFailure
          ? null
          : insightsFailure ?? this.insightsFailure,
      isTailoredCvAvailable:
          isTailoredCvAvailable ?? this.isTailoredCvAvailable,
    );
  }

  @override
  List<Object?> get props => [
    id,
    status,
    jobOpening,
    loadFailure,
    applyFailure,
    insightsStatus,
    insightsController,
    insightsSurfaceIds,
    insightsFailure,
    isTailoredCvAvailable,
  ];
}
