import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/route/route.dart';

void main() {
  group('RouteObserverWidget', () {
    testWidgets(
      'should call onResume when the observed route is first pushed',
      (tester) async {
        var resumeCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            navigatorObservers: [routeObserver],
            home: RouteObserverWidget(
              onResume: () => resumeCount++,
              child: const SizedBox.shrink(),
            ),
          ),
        );
        await tester.pump();

        expect(resumeCount, 1);
      },
    );

    testWidgets(
      'should call onPause and onResume when another route is pushed then popped',
      (tester) async {
        var resumeCount = 0;
        var pauseCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            navigatorObservers: [routeObserver],
            home: RouteObserverWidget(
              onResume: () => resumeCount++,
              onPause: () => pauseCount++,
              child: Builder(
                builder: (context) {
                  return TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const Scaffold(body: Text('Next')),
                        ),
                      );
                    },
                    child: const Text('Push'),
                  );
                },
              ),
            ),
          ),
        );
        await tester.pump();

        await tester.tap(find.text('Push'));
        await tester.pumpAndSettle();
        expect(pauseCount, 1);

        Navigator.of(tester.element(find.text('Next'))).pop();
        await tester.pumpAndSettle();

        expect(resumeCount, 2);
      },
    );

    testWidgets('should call onStop when the observed route is popped', (
      tester,
    ) async {
      var stopCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          navigatorObservers: [routeObserver],
          home: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => RouteObserverWidget(
                        onStop: () => stopCount++,
                        child: Builder(
                          builder: (context) {
                            return TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Pop observed'),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
                child: const Text('Push observed'),
              );
            },
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Push observed'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pop observed'));
      await tester.pumpAndSettle();

      expect(stopCount, 1);
    });
  });
}
