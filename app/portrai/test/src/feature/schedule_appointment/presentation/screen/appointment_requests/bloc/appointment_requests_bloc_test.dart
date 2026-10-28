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
  });

  group('AppointmentRequestsBloc', () {
    late MockGetAppointmentRequestsUseCase getAppointmentRequestsUseCase;
    late MockDecideAppointmentRequestUseCase decideAppointmentRequestUseCase;
    late MockAppointmentRequestsTrackingDelegate trackingDelegate;

    final request = receivedAppointmentRequestEntityFixture();
    final otherRequest = receivedAppointmentRequestEntityFixture(id: 'other');

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
      'should load the requests when started',
      build: buildBloc,
      act: (bloc) => bloc.add(const AppointmentRequestsStartedEvent()),
      expect: () => [
        const LoadingState(),
        LoadedState(requests: [request, otherRequest]),
      ],
      verify: (_) => verify(() => trackingDelegate.trackScreenView()).called(1),
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
        getAppointmentRequestsUseCase.stubCall(Right([request]));
        bloc.add(const AppointmentRequestsRetryClickEvent());
      },
      expect: () => [
        const LoadingState(),
        const ErrorState(GetAppointmentRequestsNetworkFailure()),
        const LoadingState(),
        LoadedState(requests: [request]),
      ],
    );

    blocTest<AppointmentRequestsBloc, AppointmentRequestsState>(
      'should save the answer and show the request with its new status',
      build: buildBloc,
      seed: () => LoadedState(requests: [request, otherRequest]),
      act: (bloc) => bloc.add(
        AppointmentRequestDecisionClickEvent(
          requestId: request.id,
          decision: AppointmentDecision.accept,
        ),
      ),
      expect: () => [
        LoadedState(
          requests: [request, otherRequest],
          decidingRequestId: request.id,
        ),
        LoadedState(
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
      seed: () => LoadedState(requests: [request]),
      act: (bloc) => bloc.add(
        AppointmentRequestDecisionClickEvent(
          requestId: request.id,
          decision: AppointmentDecision.decline,
        ),
      ),
      expect: () => [
        LoadedState(requests: [request], decidingRequestId: request.id),
        LoadedState(
          requests: [request],
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
        'should show the failure and load the requests again on '
        '${failure.runtimeType}',
        setUp: () {
          decideAppointmentRequestUseCase.stubCall(Left(failure));
          getAppointmentRequestsUseCase.stubCall(const Right([]));
        },
        build: buildBloc,
        seed: () => LoadedState(requests: [request]),
        act: (bloc) => bloc.add(
          AppointmentRequestDecisionClickEvent(
            requestId: request.id,
            decision: AppointmentDecision.accept,
          ),
        ),
        expect: () => [
          LoadedState(requests: [request], decidingRequestId: request.id),
          LoadedState(requests: [request], actionFailure: failure),
          const LoadingState(),
          const LoadedState(requests: []),
        ],
      );
    }

    blocTest<AppointmentRequestsBloc, AppointmentRequestsState>(
      'should ignore an answer while another one is being saved',
      build: buildBloc,
      seed: () => LoadedState(
        requests: [request, otherRequest],
        decidingRequestId: request.id,
      ),
      act: (bloc) => bloc.add(
        AppointmentRequestDecisionClickEvent(
          requestId: otherRequest.id,
          decision: AppointmentDecision.accept,
        ),
      ),
      expect: () => <AppointmentRequestsState>[],
      verify: (_) => verifyNever(() => decideAppointmentRequestUseCase(any())),
    );
  });

  group('LoadedState', () {
    final now = DateTime.utc(2026, 11);
    final past = receivedAppointmentRequestEntityFixture(
      id: 'past',
      slotStart: DateTime.utc(2026, 10, 30),
    );
    final answered = receivedAppointmentRequestEntityFixture(
      id: 'answered',
      slotStart: DateTime.utc(2026, 11, 2),
      status: AppointmentRequestStatus.declined,
    );
    final soon = receivedAppointmentRequestEntityFixture(
      id: 'soon',
      slotStart: DateTime.utc(2026, 11, 3),
    );
    final later = receivedAppointmentRequestEntityFixture(
      id: 'later',
      slotStart: DateTime.utc(2026, 11, 5),
    );
    final state = LoadedState(requests: [past, answered, soon, later]);

    test('should list the unanswered upcoming requests earliest first', () {
      expect(state.openRequests(now).map((request) => request.id), [
        'soon',
        'later',
      ]);
    });

    test('should list the answered and past requests latest first', () {
      expect(state.closedRequests(now).map((request) => request.id), [
        'answered',
        'past',
      ]);
    });
  });
}
