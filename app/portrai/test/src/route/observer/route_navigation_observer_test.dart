import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/route/route.dart';

import '../../../mock/utility/mock_log_reporter.dart';

void main() {
  group('RouteNavigationObserver', () {
    late MockLogReporter logReporter;
    late RouteNavigationObserver observer;
    late Route<void> route;
    late Route<void> previousRoute;

    setUp(() {
      logReporter = MockLogReporter();
      observer = RouteNavigationObserver(logReporter);
      route = MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'current'),
        builder: (_) => const SizedBox.shrink(),
      );
      previousRoute = MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'previous'),
        builder: (_) => const SizedBox.shrink(),
      );
    });

    test('should log the route names when a route is pushed', () {
      observer.didPush(route, previousRoute);

      verify(
        () => logReporter.debug(
          'New route pushed: current, previous route was: previous',
          tag: 'RouteNavigationObserver',
        ),
      ).called(1);
    });

    test('should log the route names when a route is popped', () {
      observer.didPop(route, previousRoute);

      verify(
        () => logReporter.debug(
          'Route popped: current, previous route was: previous',
          tag: 'RouteNavigationObserver',
        ),
      ).called(1);
    });
  });
}
