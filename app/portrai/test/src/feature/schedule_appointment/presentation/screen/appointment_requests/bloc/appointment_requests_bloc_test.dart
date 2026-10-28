import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/schedule_appointment/domain/_domain.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/screen/appointment_requests/bloc/_bloc.dart';
import 'package:use_case/use_case.dart';

import '../../../../../../../mock/feature/schedule_appointment/domain/entity/received_appointment_request_entity_fixture.dart';
import '../../../../../../../mock/feature/schedule_appointment/domain/use_case/mock_decide_appointment_request_use_case.dart';
import '../../../../../../../mock/feature/schedule_appointment/domain/use_case/mock_get_appointment_requests_use_case.dart';
import '../../../../../../../mock/feature/schedule_appointment/presentation/screen/appointment_requests/tracking/mock_appointment_requests_tracking_delegate.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(
      const DecideAppointmentRequestParam(
        requestId: 'fallback',
        decision: AppointmentDecision.accept,
      ),
    );
    registerFallbackValue(DateTime(2026));
  });

  group('AppointmentRequestsBloc', () {
    late MockGetAppointmentRequestsUseCase getAppointmentRequestsUseCase;
    late MockDecideAppointmentRequestUseCase decideAppointmentRequestUseCase;
    late MockAppointmentRequestsTrackingDelegate trackingDelegate;

    final request = receivedAppointmentRequestEntityFixture();
    final otherRequest = receivedAppointmentRequestEntityFixture(
      id: 'other',
      slotStart: DateTime.utc(2099, 11, 20, 14),
    );
    final requestWeek = appointmentWeekStartOf(request.slotStart);
    LoadedState loaded({List<ReceivedAppointmentRequestEntity>? requests}) =>
        LoadedState(
          requests: requests ?? [request, otherRequest],
          weekStart: requestWeek,
        );

    setUp(() {
      getAppointmentRequestsUseCase = MockGetAppointmentRequestsUseCase()
        ..stubCall(Right([request, otherRequest]));
      decideAppointmentRequestUseCase = MockDecideAppointmentRequestUseCase()
        ..stubCall(const Right(null));
      trackingDelegate = MockAppointmentRequestsTrackingDelegate();
    });

    AppointmentRequestsBloc buildBloc() => AppointmentRequestsBloc(
      getAppointmentRequestsUseCase,
      decideAppointmentRequestUseCase,
      trackingDelegate,
    );

    blocTest<AppointmentRequestsBloc, AppointmentRequestsState>(
      'should load the requests on the week of the next one to answer when '
      'started',
      build: buildBloc,
      act: (bloc) => bloc.add(const AppointmentRequestsStartedEvent()),
      expect: () => [const LoadingState(), loaded()],
      verify: (_) => verify(() => trackingDelegate.trackScreenView()).called(1),
    );

    blocTest<AppointmentRequestsBloc, AppointmentRequestsState>(
      'should open on this week when no request waits for an answer',
      setUp: () => getAppointmentRequestsUseCase.stubCall(const Right([])),
      build: buildBloc,
      act: (bloc) => bloc.add(const AppointmentRequestsStartedEvent()),
      expect: () => [
        const LoadingState(),
        LoadedState(
          requests: const [],
          weekStart: appointmentWeekStartOf(DateTime.now()),
        ),
      ],
    );

    blocTest<AppointmentRequestsBloc, AppointmentRequestsState>(
      'should show the failure when the requests fail to load, and load '
      'again on retry',
      setUp: () => getAppointmentRequestsUseCase.stubCall(
        const Left(GetAppointmentRequestsNetworkFailure()),
      ),
      build: buildBloc,
      act: (bloc) async {
        bloc.add(const AppointmentRequestsStartedEvent());
        await Future<void>.delayed(Duration.zero);
        getAppointmentRequestsUseCase.stubCall(Right([request, otherRequest]));
        bloc.add(const AppointmentRequestsRetryClickEvent());
      },
      expect: () => [
        const LoadingState(),
        const ErrorState(GetAppointmentRequestsNetworkFailure()),
        const LoadingState(),
        loaded(),
      ],
    );

    blocTest<AppointmentRequestsBloc, AppointmentRequestsState>(
      'should save the answer and show the request with its new status',
      build: buildBloc,
      seed: loaded,
      act: (bloc) => bloc.add(
        AppointmentRequestDecisionClickEvent(
          requestId: request.id,
          decision: AppointmentDecision.accept,
        ),
      ),
      expect: () => [
        loaded().copyWith(decidingRequestId: request.id),
        loaded(
          requests: [
            request.copyWith(status: AppointmentRequestStatus.accepted),
            otherRequest,
          ],
        ),
      ],
      verify: (_) {
        verify(
          () => decideAppointmentRequestUseCase(
            DecideAppointmentRequestParam(
              requestId: request.id,
              decision: AppointmentDecision.accept,
            ),
          ),
        ).called(1);
        verify(
          () => trackingDelegate.trackDecisionClick(
            decision: 'accept',
            requestId: request.id,
          ),
        ).called(1);
      },
    );

    blocTest<AppointmentRequestsBloc, AppointmentRequestsState>(
      'should keep the request and show the failure when the answer cannot '
      'be sent',
      setUp: () => decideAppointmentRequestUseCase.stubCall(
        const Left(DecideAppointmentRequestNetworkFailure()),
      ),
      build: buildBloc,
      seed: loaded,
      act: (bloc) => bloc.add(
        AppointmentRequestDecisionClickEvent(
          requestId: request.id,
          decision: AppointmentDecision.decline,
        ),
      ),
      expect: () => [
        loaded().copyWith(decidingRequestId: request.id),
        loaded().copyWith(
          actionFailure: const DecideAppointmentRequestNetworkFailure(),
        ),
      ],
      verify: (_) => verifyNever(() => getAppointmentRequestsUseCase()),
    );

    for (final failure in [
      const DecideAppointmentRequestNotFoundFailure(),
      const DecideAppointmentRequestPermissionDeniedFailure(),
    ]) {
      blocTest<AppointmentRequestsBloc, AppointmentRequestsState>(
        'should show the failure and load the requests again, keeping the '
        'search, on ${failure.runtimeType}',
        setUp: () {
          decideAppointmentRequestUseCase.stubCall(Left(failure));
          getAppointmentRequestsUseCase.stubCall(Right([otherRequest]));
        },
        build: buildBloc,
        seed: () => loaded().copyWith(searchQuery: 'alex'),
        act: (bloc) => bloc.add(
          AppointmentRequestDecisionClickEvent(
            requestId: request.id,
            decision: AppointmentDecision.accept,
          ),
        ),
        expect: () => [
          loaded().copyWith(searchQuery: 'alex', decidingRequestId: request.id),
          loaded().copyWith(searchQuery: 'alex', actionFailure: failure),
          const LoadingState(),
          loaded(requests: [otherRequest]).copyWith(searchQuery: 'alex'),
        ],
      );
    }

    blocTest<AppointmentRequestsBloc, AppointmentRequestsState>(
      'should ignore an answer while another one is being saved',
      build: buildBloc,
      seed: () => loaded().copyWith(decidingRequestId: request.id),
      act: (bloc) => bloc.add(
        AppointmentRequestDecisionClickEvent(
          requestId: otherRequest.id,
          decision: AppointmentDecision.accept,
        ),
      ),
      expect: () => <AppointmentRequestsState>[],
      verify: (_) => verifyNever(() => decideAppointmentRequestUseCase(any())),
    );

    blocTest<AppointmentRequestsBloc, AppointmentRequestsState>(
      'should keep the search query when it changes',
      build: buildBloc,
      seed: loaded,
      act: (bloc) =>
          bloc.add(const AppointmentRequestsSearchChangedEvent('flutter')),
      expect: () => [loaded().copyWith(searchQuery: 'flutter')],
    );

    blocTest<AppointmentRequestsBloc, AppointmentRequestsState>(
      'should turn a filter on and track it, and off when tapped again',
      build: buildBloc,
      seed: loaded,
      act: (bloc) => bloc
        ..add(
          const AppointmentRequestsFilterClickEvent(
            AppointmentRequestsFilter.accepted,
          ),
        )
        ..add(
          const AppointmentRequestsFilterClickEvent(
            AppointmentRequestsFilter.accepted,
          ),
        ),
      expect: () => [
        loaded().copyWith(filter: AppointmentRequestsFilter.accepted),
        loaded(),
      ],
      verify: (_) => verify(
        () => trackingDelegate.trackFilterSelection('accepted'),
      ).called(1),
    );

    blocTest<AppointmentRequestsBloc, AppointmentRequestsState>(
      'should pick a day and track it, and show every day when tapped again',
      build: buildBloc,
      seed: loaded,
      act: (bloc) {
        final day = appointmentDayOf(request.slotStart);
        bloc
          ..add(AppointmentRequestsDayClickEvent(day))
          ..add(AppointmentRequestsDayClickEvent(day));
      },
      expect: () => [
        loaded().copyWith(selectedDay: appointmentDayOf(request.slotStart)),
        loaded(),
      ],
      verify: (_) => verify(
        () =>
            trackingDelegate.trackDayClick(appointmentDayOf(request.slotStart)),
      ).called(1),
    );

    blocTest<AppointmentRequestsBloc, AppointmentRequestsState>(
      'should show another week and clear the picked day',
      build: buildBloc,
      seed: () =>
          loaded().copyWith(selectedDay: appointmentDayOf(request.slotStart)),
      act: (bloc) => bloc.add(
        AppointmentRequestsWeekClickEvent(
          label: 'next_week',
          weekStart: DateTime(
            requestWeek.year,
            requestWeek.month,
            requestWeek.day + 7,
          ),
        ),
      ),
      expect: () => [
        loaded().copyWith(
          weekStart: DateTime(
            requestWeek.year,
            requestWeek.month,
            requestWeek.day + 7,
          ),
        ),
      ],
      verify: (_) =>
          verify(() => trackingDelegate.trackWeekClick('next_week')).called(1),
    );

    blocTest<AppointmentRequestsBloc, AppointmentRequestsState>(
      'should clear the search, the filter and the day',
      build: buildBloc,
      seed: () => loaded().copyWith(
        searchQuery: 'alex',
        filter: AppointmentRequestsFilter.waiting,
        selectedDay: appointmentDayOf(request.slotStart),
      ),
      act: (bloc) =>
          bloc.add(const AppointmentRequestsClearFiltersClickEvent()),
      expect: () => [loaded()],
      verify: (_) =>
          verify(() => trackingDelegate.trackClearFiltersClick()).called(1),
    );
  });

  group('LoadedState', () {
    final now = DateTime.utc(2026, 11);
    final past = receivedAppointmentRequestEntityFixture(
      id: 'past',
      slotStart: DateTime.utc(2026, 10, 30, 12),
    );
    final declined = receivedAppointmentRequestEntityFixture(
      id: 'declined',
      slotStart: DateTime.utc(2026, 11, 2, 12),
      status: AppointmentRequestStatus.declined,
    );
    final accepted = receivedAppointmentRequestEntityFixture(
      id: 'accepted',
      name: 'Sam Roe',
      slotStart: DateTime.utc(2026, 11, 3, 12),
      status: AppointmentRequestStatus.accepted,
    );
    final soon = receivedAppointmentRequestEntityFixture(
      id: 'soon',
      slotStart: DateTime.utc(2026, 11, 4, 12),
    );
    final later = receivedAppointmentRequestEntityFixture(
      id: 'later',
      slotStart: DateTime.utc(2026, 11, 12, 12),
    );
    final state = LoadedState(
      requests: [past, declined, accepted, soon, later],
      weekStart: appointmentWeekStartOf(soon.slotStart),
    );

    List<String> idsOf(List<ReceivedAppointmentRequestEntity> requests) =>
        requests.map((request) => request.id).toList();

    test('should sort the requests into waiting, coming up and earlier', () {
      expect(idsOf(state.waitingRequests(now)), ['soon', 'later']);
      expect(idsOf(state.upcomingRequests(now)), ['accepted']);
      expect(idsOf(state.earlierRequests(now)), ['declined', 'past']);
    });

    test('should count the requests of each filter', () {
      expect(state.countOf(AppointmentRequestsFilter.waiting, now), 2);
      expect(state.countOf(AppointmentRequestsFilter.accepted, now), 1);
      expect(state.countOf(AppointmentRequestsFilter.declined, now), 1);
      expect(state.countOf(AppointmentRequestsFilter.unanswered, now), 1);
    });

    test('should match every search word in the name, email, topic or '
        'message', () {
      expect(
        idsOf(state.copyWith(searchQuery: 'sam flutter').visibleRequests(now)),
        ['accepted'],
      );
    });

    test('should narrow the list to the filter and the picked day', () {
      expect(
        idsOf(
          state
              .copyWith(filter: AppointmentRequestsFilter.waiting)
              .visibleRequests(now),
        ),
        ['soon', 'later'],
      );
      expect(
        idsOf(
          state
              .copyWith(selectedDay: appointmentDayOf(soon.slotStart))
              .visibleRequests(now),
        ),
        ['soon'],
      );
    });

    test('should put the week requests on their days, Monday first', () {
      final weekRequests = state.weekRequests(now);

      expect(weekRequests.keys.first.weekday, DateTime.monday);
      expect(weekRequests.length, 7);
      expect(weekRequests[appointmentDayOf(soon.slotStart)], [soon]);
      expect(
        weekRequests.values.expand((requests) => requests),
        isNot(contains(later)),
      );
    });
  });
}
