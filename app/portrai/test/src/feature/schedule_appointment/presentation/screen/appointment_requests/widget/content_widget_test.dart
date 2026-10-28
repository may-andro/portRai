import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/schedule_appointment/domain/_domain.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/screen/appointment_requests/bloc/_bloc.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/screen/appointment_requests/widget/_widget.dart';
import 'package:portrai/src/widget/screen_content_widget.dart';

import '../../../../../../../mock/feature/schedule_appointment/domain/entity/received_appointment_request_entity_fixture.dart';
import '../../../../../../../mock/feature/schedule_appointment/presentation/screen/appointment_requests/bloc/mock_appointment_requests_bloc.dart';
import '../../../../../../../util/animated_page_test_util.dart';
import '../../../../../../../util/test_wrapper_widget.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(const AppointmentRequestsStartedEvent());
  });

  final openRequest = receivedAppointmentRequestEntityFixture(id: 'open');
  final acceptedRequest = receivedAppointmentRequestEntityFixture(
    id: 'accepted',
    name: 'Sam Roe',
    message: '',
    slotStart: DateTime.utc(2099, 11, 5, 14),
    status: AppointmentRequestStatus.accepted,
  );
  final weekStart = appointmentWeekStartOf(openRequest.slotStart);

  LoadedState loaded(List<ReceivedAppointmentRequestEntity> requests) =>
      LoadedState(requests: requests, weekStart: weekStart);

  Future<MockAppointmentRequestsBloc> pumpContent(
    WidgetTester tester,
    AppointmentRequestsState state, {
    Size size = const Size(1440, 2400),
  }) async {
    setUpAnimatedPage(tester, size: size);
    final bloc = MockAppointmentRequestsBloc()..stubState(state);
    addTearDown(bloc.close);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => ScreenFooterProviderWidget(
            footer: const Text('footer'),
            child: BlocProvider<AppointmentRequestsBloc>.value(
              value: bloc,
              child: const Scaffold(body: ContentWidget()),
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      TestWidgetWrapper(routerConfig: router, child: const SizedBox()),
    );
    await pumpAnimations(tester);
    return bloc;
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets('should show the week, the sections and each request with its '
      'details', (tester) async {
    await pumpContent(tester, loaded([openRequest, acceptedRequest]));

    expect(find.text('Appointment requests'), findsOneWidget);
    expect(find.text('Your week'), findsOneWidget);
    expect(find.text('Waiting for your answer'), findsOneWidget);
    expect(find.text('Coming up'), findsOneWidget);
    expect(find.text('Alex Doe'), findsOneWidget);
    expect(find.text('alex@example.com'), findsWidgets);
    expect(find.text('Looking forward to it.'), findsOneWidget);
    expect(find.text('Sam Roe'), findsOneWidget);
    // Only the waiting request can be answered.
    expect(find.text('Accept'), findsOneWidget);
    expect(find.text('Decline'), findsOneWidget);
  });

  for (final (device, size) in [
    ('a phone', const Size(360, 2400)),
    ('a tablet', const Size(800, 2400)),
  ]) {
    testWidgets('should lay out the week and the cards on $device', (
      tester,
    ) async {
      await pumpContent(
        tester,
        loaded([
          openRequest,
          acceptedRequest,
        ]).copyWith(selectedDay: appointmentDayOf(openRequest.slotStart)),
        size: size,
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Alex Doe'), findsOneWidget);
    });
  }

  testWidgets('should say so before any request arrived', (tester) async {
    await pumpContent(tester, loaded(const []));

    expect(find.textContaining('No appointment requests yet.'), findsOneWidget);
    expect(find.text('Your week'), findsNothing);
  });

  testWidgets('should say when every request has an answer', (tester) async {
    await pumpContent(tester, loaded([acceptedRequest]));

    expect(
      find.text("You're all caught up. No request is waiting for your answer."),
      findsOneWidget,
    );
    expect(find.text('Accept'), findsNothing);
  });

  testWidgets('should offer to clear the filters when nothing matches', (
    tester,
  ) async {
    final bloc = await pumpContent(
      tester,
      loaded([openRequest]).copyWith(searchQuery: 'nobody'),
    );

    expect(find.text('No requests match your search.'), findsOneWidget);
    await tester.tap(find.text('Clear filters').last);
    await settle(tester);

    verify(
      () => bloc.add(const AppointmentRequestsClearFiltersClickEvent()),
    ).called(1);
  });

  testWidgets('should send the search, the filter, the day and the week to '
      'the bloc', (tester) async {
    final bloc = await pumpContent(tester, loaded([openRequest]));

    await tester.enterText(find.byType(TextField), 'alex');
    await settle(tester);
    verify(
      () => bloc.add(const AppointmentRequestsSearchChangedEvent('alex')),
    ).called(1);

    await tester.tap(find.widgetWithText(FilterChip, 'Waiting'));
    await settle(tester);
    verify(
      () => bloc.add(
        const AppointmentRequestsFilterClickEvent(
          AppointmentRequestsFilter.waiting,
        ),
      ),
    ).called(1);

    final day = appointmentDayOf(openRequest.slotStart);
    await tester.tap(find.text('${day.day}').first);
    await settle(tester);
    verify(() => bloc.add(AppointmentRequestsDayClickEvent(day))).called(1);

    await tester.tap(find.byTooltip('Next week'));
    await settle(tester);
    verify(
      () => bloc.add(
        AppointmentRequestsWeekClickEvent(
          label: 'next_week',
          weekStart: DateTime(
            weekStart.year,
            weekStart.month,
            weekStart.day + 7,
          ),
        ),
      ),
    ).called(1);
  });

  for (final (button, decision) in [
    ('Accept', AppointmentDecision.accept),
    ('Decline', AppointmentDecision.decline),
  ]) {
    testWidgets('should send the answer once the owner confirms $button', (
      tester,
    ) async {
      final bloc = await pumpContent(tester, loaded([openRequest]));

      await tester.tap(find.text(button));
      await settle(tester);
      await tester.tap(find.text(button).last);
      await settle(tester);

      verify(
        () => bloc.add(
          AppointmentRequestDecisionClickEvent(
            requestId: 'open',
            decision: decision,
          ),
        ),
      ).called(1);
    });
  }

  testWidgets('should not send an answer when the owner cancels', (
    tester,
  ) async {
    final bloc = await pumpContent(tester, loaded([openRequest]));

    await tester.tap(find.text('Accept'));
    await settle(tester);
    expect(find.text('Accept this appointment?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await settle(tester);

    expect(find.text('Accept this appointment?'), findsNothing);
    verifyNever(() => bloc.add(any()));
  });
}
