import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/route/route.dart';

import '../../../mock/utility/mock_log_reporter.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(StackTrace.empty);
    registerFallbackValue(Exception('fallback'));
  });

  group('ModuleRouteController', () {
    late MockLogReporter logReporter;
    late ModuleRouteController controller;
    late ModuleRoute route;

    setUp(() {
      logReporter = MockLogReporter();
      controller = ModuleRouteController(logReporter);
      route = ModuleRoute(
        name: 'home',
        path: '/',
        builder: (_, _, _) => const SizedBox.shrink(),
      );
    });

    test('should register a route when a new route is added', () {
      controller.register(route);

      expect(controller.allRoutes, [route]);
    });

    test(
      'should ignore duplicate routes when the same route is registered twice',
      () {
        controller.register(route);
        controller.register(route);

        expect(controller.allRoutes, [route]);
        verify(
          () => logReporter.error(
            any<String>(),
            stacktrace: any<StackTrace>(named: 'stacktrace'),
            error: any<Object>(named: 'error'),
            tag: 'ModuleRouteController',
          ),
        ).called(1);
      },
    );

    test('should expose an unmodifiable list when reading all routes', () {
      controller.register(route);

      expect(
        () => controller.allRoutes.add(
          ModuleRoute(
            name: 'details',
            path: '/details',
            builder: (_, _, _) => const SizedBox.shrink(),
          ),
        ),
        throwsUnsupportedError,
      );
    });
  });
}
