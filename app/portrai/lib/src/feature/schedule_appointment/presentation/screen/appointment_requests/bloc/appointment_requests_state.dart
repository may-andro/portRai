import 'package:equatable/equatable.dart';
import 'package:portrai/src/feature/schedule_appointment/domain/_domain.dart';
import 'package:use_case/use_case.dart';

/// Narrows the list to the requests in one state.
enum AppointmentRequestsFilter {
  waiting,
  accepted,
  declined,
  unanswered;

  bool matches(ReceivedAppointmentRequestEntity request, DateTime now) =>
      switch (this) {
        AppointmentRequestsFilter.waiting => request.isAnswerableAt(now),
        AppointmentRequestsFilter.accepted =>
          request.status == AppointmentRequestStatus.accepted,
        AppointmentRequestsFilter.declined =>
          request.status == AppointmentRequestStatus.declined,
        AppointmentRequestsFilter.unanswered =>
          request.status == AppointmentRequestStatus.requested &&
              !request.isAnswerableAt(now),
      };
}

/// The local midnight of the Monday in the week of [dateTime].
DateTime appointmentWeekStartOf(DateTime dateTime) {
  final local = dateTime.toLocal();
  return DateTime(local.year, local.month, local.day - (local.weekday - 1));
}

/// The local midnight of the day of [dateTime].
DateTime appointmentDayOf(DateTime dateTime) {
  final local = dateTime.toLocal();
  return DateTime(local.year, local.month, local.day);
}

sealed class AppointmentRequestsState extends Equatable {
  const AppointmentRequestsState();

  @override
  List<Object?> get props => [];
}

final class LoadingState extends AppointmentRequestsState {
  const LoadingState();
}

final class ErrorState extends AppointmentRequestsState {
  const ErrorState(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

final class LoadedState extends AppointmentRequestsState {
  const LoadedState({
    required this.requests,
    required this.weekStart,
    this.searchQuery = '',
    this.filter,
    this.selectedDay,
    this.decidingRequestId,
    this.actionFailure,
  });

  /// Earliest slot first.
  final List<ReceivedAppointmentRequestEntity> requests;

  /// The local midnight of the Monday the week timeline shows.
  final DateTime weekStart;

  final String searchQuery;

  /// Shows every request when null.
  final AppointmentRequestsFilter? filter;

  /// The local midnight of the day picked in the week timeline, if any.
  final DateTime? selectedDay;

  /// The request whose answer is being saved, so its buttons wait.
  final String? decidingRequestId;

  /// Why an answer could not be saved. Shown once.
  final Failure? actionFailure;

  bool get isNarrowed =>
      searchQuery.trim().isNotEmpty || filter != null || selectedDay != null;

  /// The seven local days of the week timeline, Monday first.
  List<DateTime> get weekDays => [
    for (var day = 0; day < DateTime.daysPerWeek; day++)
      DateTime(weekStart.year, weekStart.month, weekStart.day + day),
  ];

  /// How many requests [filter] would show at [now].
  int countOf(AppointmentRequestsFilter filter, DateTime now) =>
      requests.where((request) => filter.matches(request, now)).length;

  /// The requests that match the search and the filter, on any day.
  List<ReceivedAppointmentRequestEntity> matchingRequests(DateTime now) {
    final searchWords = searchQuery
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    return requests.where((request) {
      final searchableText = [
        request.name,
        request.email,
        request.topic,
        request.message,
      ].join(' ').toLowerCase();
      return searchWords.every(searchableText.contains) &&
          (filter?.matches(request, now) ?? true);
    }).toList();
  }

  /// The matching requests on each day of the week timeline.
  Map<DateTime, List<ReceivedAppointmentRequestEntity>> weekRequests(
    DateTime now,
  ) {
    final byDay = {
      for (final day in weekDays) day: <ReceivedAppointmentRequestEntity>[],
    };
    for (final request in matchingRequests(now)) {
      byDay[appointmentDayOf(request.slotStart)]?.add(request);
    }
    return byDay;
  }

  /// The matching requests, on [selectedDay] when one is picked.
  List<ReceivedAppointmentRequestEntity> visibleRequests(DateTime now) {
    final day = selectedDay;
    final matching = matchingRequests(now);
    if (day == null) return matching;
    return matching
        .where((request) => appointmentDayOf(request.slotStart) == day)
        .toList();
  }

  /// The visible requests the owner can still answer, earliest first.
  List<ReceivedAppointmentRequestEntity> waitingRequests(DateTime now) =>
      visibleRequests(
        now,
      ).where((request) => request.isAnswerableAt(now)).toList();

  /// The visible accepted requests still to come, earliest first.
  List<ReceivedAppointmentRequestEntity> upcomingRequests(DateTime now) =>
      visibleRequests(now)
          .where(
            (request) =>
                request.status == AppointmentRequestStatus.accepted &&
                request.slotStart.isAfter(now),
          )
          .toList();

  /// The other visible requests: declined, past or never answered, latest
  /// first.
  List<ReceivedAppointmentRequestEntity> earlierRequests(DateTime now) {
    final waiting = waitingRequests(now).toSet();
    final upcoming = upcomingRequests(now).toSet();
    return visibleRequests(now).reversed
        .where(
          (request) =>
              !waiting.contains(request) && !upcoming.contains(request),
        )
        .toList();
  }

  LoadedState copyWith({
    List<ReceivedAppointmentRequestEntity>? requests,
    DateTime? weekStart,
    String? searchQuery,
    AppointmentRequestsFilter? filter,
    bool clearFilter = false,
    DateTime? selectedDay,
    bool clearSelectedDay = false,
    String? decidingRequestId,
    bool clearDecidingRequestId = false,
    Failure? actionFailure,
    bool clearActionFailure = false,
  }) {
    return LoadedState(
      requests: requests ?? this.requests,
      weekStart: weekStart ?? this.weekStart,
      searchQuery: searchQuery ?? this.searchQuery,
      filter: clearFilter ? null : filter ?? this.filter,
      selectedDay: clearSelectedDay ? null : selectedDay ?? this.selectedDay,
      decidingRequestId: clearDecidingRequestId
          ? null
          : decidingRequestId ?? this.decidingRequestId,
      actionFailure: clearActionFailure
          ? null
          : actionFailure ?? this.actionFailure,
    );
  }

  @override
  List<Object?> get props => [
    requests,
    weekStart,
    searchQuery,
    filter,
    selectedDay,
    decidingRequestId,
    actionFailure,
  ];
}
