import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/call_booking/presentation/route/_route.dart';
import 'package:portrai/src/feature/call_booking/presentation/widget/_widget.dart';
import 'package:portrai/src/feature/call_booking/presentation/widget/book_call_entry/bloc/_bloc.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';

import '../../../../../../mock/feature/call_booking/presentation/widget/book_call_entry/bloc/mock_book_call_entry_bloc.dart';
import '../../../../../../util/test_wrapper_widget.dart';

void main() {
  tearDown(appServiceLocator.reset);

  Future<MockBookCallEntryBloc> pump(
    WidgetTester tester, {
    required bool isAvailable,
  }) async {
    final bloc = MockBookCallEntryBloc()
      ..stubAvailable(isAvailable)
      ..registerFactory();
    final bookCallRoute = CallBookingModuleRoute.bookCall;
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: BookCallEntryWidget(
              trackingLabel: 'test_book_call_button',
              topic: 'App Development',
              fallback: const Text('Email me'),
              builder: (context, onBookCall) =>
                  TextButton(onPressed: onBookCall, child: const Text('Book')),
            ),
          ),
        ),
        GoRoute(
          name: bookCallRoute.name,
          path: bookCallRoute.path,
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

  group('BookCallEntryWidget', () {
    testWidgets('should build the entry when booking is on', (tester) async {
      await pump(tester, isAvailable: true);

      expect(find.text('Book'), findsOneWidget);
      expect(find.text('Email me'), findsNothing);
    });

    testWidgets('should show the fallback when booking is off', (tester) async {
      await pump(tester, isAvailable: false);

      expect(find.text('Email me'), findsOneWidget);
      expect(find.text('Book'), findsNothing);
    });

    testWidgets('should track the tap and open booking with the topic', (
      tester,
    ) async {
      final bloc = await pump(tester, isAvailable: true);

      await tester.tap(find.text('Book'));
      await tester.pumpAndSettle();

      expect(find.text('Booking App Development'), findsOneWidget);

      verify(
        () => bloc.add(
          const BookCallClickEvent(
            label: 'test_book_call_button',
            topic: 'App Development',
          ),
        ),
      ).called(1);
    });
  });
}
