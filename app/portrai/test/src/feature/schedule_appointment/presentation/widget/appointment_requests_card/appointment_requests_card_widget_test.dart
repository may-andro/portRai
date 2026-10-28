import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/route/_route.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/widget/appointment_requests_card/appointment_requests_card_widget.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/widget/appointment_requests_card/bloc/_bloc.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';

import '../../../../../../mock/feature/schedule_appointment/presentation/widget/appointment_requests_card/bloc/mock_appointment_requests_card_bloc.dart';
import '../../../../../../util/test_wrapper_widget.dart';

void main() {
  late MockAppointmentRequestsCardBloc bloc;

  setUp(() async {
    await appServiceLocator.reset();
    bloc = MockAppointmentRequestsCardBloc()
      ..stubState()
      ..registerFactory();
  });

  tearDown(() => appServiceLocator.reset());

  testWidgets('should track the tap and open the appointment requests when '
      'the card is tapped', (tester) async {
    final route = ScheduleAppointmentModuleRoute.appointmentRequests;
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) =>
              const Scaffold(body: AppointmentRequestsCardWidget()),
        ),
        GoRoute(
          name: route.name,
          path: route.path,
          builder: (_, _) => const Text('Appointment requests screen'),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      TestWidgetWrapper(routerConfig: router, child: const SizedBox()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Appointment requests'));
    await tester.pumpAndSettle();

    verify(
      () => bloc.add(
        const AppointmentRequestsCardClickEvent('appointment_requests_card'),
      ),
    ).called(1);
    expect(find.text('Appointment requests screen'), findsOneWidget);
  });
}
