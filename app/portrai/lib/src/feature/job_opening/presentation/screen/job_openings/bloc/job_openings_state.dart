import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:portrai/src/feature/job_opening/domain/_domain.dart';
import 'package:portrai/src/feature/job_opening/presentation/extension/_extension.dart';
import 'package:portrai/src/feature/job_opening/presentation/widget/_widget.dart';
import 'package:use_case/use_case.dart';

enum JobOpeningsStatus { loading, loaded, failed }

/// Filters in the same group widen the list, since an opening matches when
/// it fits any of them; filters in different groups narrow it.
enum JobOpeningsFilterGroup { platform, engagement, fit, freshness }

enum JobOpeningsFilter {
  flutter(JobOpeningsFilterGroup.platform),
  android(JobOpeningsFilterGroup.platform),
  ios(JobOpeningsFilterGroup.platform),
  contract(JobOpeningsFilterGroup.engagement),
  freelance(JobOpeningsFilterGroup.engagement),
  strongFit(JobOpeningsFilterGroup.fit),
  recent(JobOpeningsFilterGroup.freshness);

  const JobOpeningsFilter(this.group);

  final JobOpeningsFilterGroup group;

  bool matches(JobOpeningEntity jobOpening, DateTime now) => switch (this) {
    JobOpeningsFilter.flutter => jobOpening.platforms.contains(
      JobOpeningPlatform.flutter,
    ),
    JobOpeningsFilter.android => jobOpening.platforms.contains(
      JobOpeningPlatform.android,
    ),
    JobOpeningsFilter.ios => jobOpening.platforms.contains(
      JobOpeningPlatform.ios,
    ),
    JobOpeningsFilter.contract =>
      jobOpening.engagement == JobOpeningEngagement.contract,
    JobOpeningsFilter.freelance =>
      jobOpening.engagement == JobOpeningEngagement.freelance,
    JobOpeningsFilter.strongFit =>
      JobFitTier.of(jobOpening.score) == JobFitTier.strong,
    JobOpeningsFilter.recent => jobOpening.isNew(now),
  };
}

@immutable
class JobOpeningsState extends Equatable {
  const JobOpeningsState({
    this.status = JobOpeningsStatus.loading,
    this.jobOpenings = const [],
    this.loadFailure,
    this.searchQuery = '',
    this.filters = const {},
    this.isSigningOut = false,
    this.isSignedOut = false,
    this.actionFailure,
  });

  final JobOpeningsStatus status;
  final List<JobOpeningEntity> jobOpenings;

  /// Why the openings could not be loaded, shown in place of the list.
  final Failure? loadFailure;

  final String searchQuery;
  final Set<JobOpeningsFilter> filters;
  final bool isSigningOut;
  final bool isSignedOut;

  /// Why signing out failed. Shown once.
  final Failure? actionFailure;

  bool get isNarrowed => searchQuery.trim().isNotEmpty || filters.isNotEmpty;

  /// [jobOpenings] that match every word of [searchQuery] and the [filters].
  List<JobOpeningEntity> visibleJobOpenings(DateTime now) {
    if (!isNarrowed) return jobOpenings;

    final searchWords = searchQuery
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    final filtersByGroup = <JobOpeningsFilterGroup, List<JobOpeningsFilter>>{};
    for (final filter in filters) {
      (filtersByGroup[filter.group] ??= []).add(filter);
    }

    return jobOpenings.where((jobOpening) {
      final searchableText = [
        jobOpening.title,
        jobOpening.company,
        ?jobOpening.location,
        jobOpening.sourceName,
        ...jobOpening.tags,
        ...jobOpening.matchedSkills,
      ].join(' ').toLowerCase();
      return searchWords.every(searchableText.contains) &&
          filtersByGroup.values.every(
            (groupFilters) =>
                groupFilters.any((filter) => filter.matches(jobOpening, now)),
          );
    }).toList();
  }

  JobOpeningsState copyWith({
    JobOpeningsStatus? status,
    List<JobOpeningEntity>? jobOpenings,
    Failure? loadFailure,
    bool clearLoadFailure = false,
    String? searchQuery,
    Set<JobOpeningsFilter>? filters,
    bool? isSigningOut,
    bool? isSignedOut,
    Failure? actionFailure,
    bool clearActionFailure = false,
  }) {
    return JobOpeningsState(
      status: status ?? this.status,
      jobOpenings: jobOpenings ?? this.jobOpenings,
      loadFailure: clearLoadFailure ? null : loadFailure ?? this.loadFailure,
      searchQuery: searchQuery ?? this.searchQuery,
      filters: filters ?? this.filters,
      isSigningOut: isSigningOut ?? this.isSigningOut,
      isSignedOut: isSignedOut ?? this.isSignedOut,
      actionFailure: clearActionFailure
          ? null
          : actionFailure ?? this.actionFailure,
    );
  }

  @override
  List<Object?> get props => [
    status,
    jobOpenings,
    loadFailure,
    searchQuery,
    filters,
    isSigningOut,
    isSignedOut,
    actionFailure,
  ];
}
