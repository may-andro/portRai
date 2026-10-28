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
    status: AppointmentRequestStatus.accepted,
  );

  Future<MockAppointmentRequestsBloc> pumpContent(
    WidgetTester tester,
    AppointmentRequestsState state,
  ) async {
    setUpAnimatedPage(tester);
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

  testWidgets('should show the open requests with answer buttons and the '
      'answered ones without', (tester) async {
    await pumpContent(
      tester,
      LoadedState(requests: [openRequest, acceptedRequest]),
    );

    expect(find.text('Waiting for your answer'), findsOneWidget);
    expect(find.text('Earlier'), findsOneWidget);
    expect(find.text('Alex Doe'), findsOneWidget);
    expect(find.text('Looking forward to it.'), findsOneWidget);
    expect(find.text('Sam Roe'), findsOneWidget);
    expect(find.text('Waiting'), findsOneWidget);
    expect(find.text('Accepted'), findsOneWidget);
    expect(find.text('Accept'), findsOneWidget);
    expect(find.text('Decline'), findsOneWidget);
  });

  testWidgets('should say so when no request waits for an answer', (
    tester,
  ) async {
    await pumpContent(tester, LoadedState(requests: [acceptedRequest]));

    expect(
      find.text('No requests are waiting for your answer.'),
      findsOneWidget,
    );
    expect(find.text('Accept'), findsNothing);
  });

  for (final (button, decision) in [
    ('Accept', AppointmentDecision.accept),
    ('Decline', AppointmentDecision.decline),
  ]) {
    testWidgets('should send the answer once the owner confirms $button', (
      tester,
    ) async {
      final bloc = await pumpContent(
        tester,
        LoadedState(requests: [openRequest]),
      );

      await tester.tap(find.text(button));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.text(button).last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

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
    final bloc = await pumpContent(
      tester,
      LoadedState(requests: [openRequest]),
    );

    await tester.tap(find.text('Accept'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Accept this appointment?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Accept this appointment?'), findsNothing);
    verifyNever(() => bloc.add(any()));
  });
}
