import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/route/_route.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/widget/_widget.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/widget/schedule_appointment_entry/bloc/_bloc.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';

import '../../../../../../mock/feature/schedule_appointment/presentation/widget/schedule_appointment_entry/bloc/mock_schedule_appointment_entry_bloc.dart';
import '../../../../../../util/test_wrapper_widget.dart';

void main() {
  tearDown(appServiceLocator.reset);

  Future<MockScheduleAppointmentEntryBloc> pump(
    WidgetTester tester, {
    required bool isAvailable,
  }) async {
    final bloc = MockScheduleAppointmentEntryBloc()
      ..stubAvailable(isAvailable)
      ..registerFactory();
    final scheduleAppointmentRoute =
        ScheduleAppointmentModuleRoute.scheduleAppointment;
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: ScheduleAppointmentEntryWidget(
              trackingLabel: 'test_schedule_appointment_button',
              topic: 'App Development',
              fallback: const Text('Email me'),
              builder: (context, onScheduleAppointment) => TextButton(
                onPressed: onScheduleAppointment,
                child: const Text('Book'),
              ),
            ),
          ),
        ),
        GoRoute(
          name: scheduleAppointmentRoute.name,
          path: scheduleAppointmentRoute.path,
          builder: (context, state) =>
              Text('Booking ${state.uri.queryParameters['topic']}'),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      TestWidgetWrapper(routerConfig: router, child: const SizedBox()),
    );
    await tester.pump();
    return bloc;
  }

  group('ScheduleAppointmentEntryWidget', () {
    testWidgets('should build the entry when scheduling is on', (tester) async {
      await pump(tester, isAvailable: true);

      expect(find.text('Book'), findsOneWidget);
      expect(find.text('Email me'), findsNothing);
    });

    testWidgets('should show the fallback when scheduling is off', (
      tester,
    ) async {
      await pump(tester, isAvailable: false);

      expect(find.text('Email me'), findsOneWidget);
      expect(find.text('Book'), findsNothing);
    });

    testWidgets('should track the tap and open scheduling with the topic', (
      tester,
    ) async {
      final bloc = await pump(tester, isAvailable: true);

      await tester.tap(find.text('Book'));
      await tester.pumpAndSettle();

      expect(find.text('Booking App Development'), findsOneWidget);

      verify(
        () => bloc.add(
          const ScheduleAppointmentClickEvent(
            label: 'test_schedule_appointment_button',
            topic: 'App Development',
          ),
        ),
      ).called(1);
    });
  });
}
