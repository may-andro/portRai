import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/local_assistant/local_assistant.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/bloc/_bloc.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/widget/assistant_launcher_widget.dart';
import 'package:portrai/src/feature/remote_assistant/remote_assistant.dart';

import '../../../../../../../mock/feature/portfolio/presentation/screen/portfolio/bloc/mock_portfolio_bloc.dart';
import '../../../../../../../util/assistant_test_fixture.dart';
import '../../../../../../../util/test_wrapper_widget.dart';

void main() {
  setUpAll(AssistantTestFixture.registerFallbacks);

  Future<void> pumpLauncher(
    WidgetTester tester,
    AssistantTestFixture fixture, {
    required VoidCallback local,
    required VoidCallback remote,
  }) async {
    final portfolio = MockPortfolioBloc()..stubState(const LoadingState());
    addTearDown(portfolio.close);
    await tester.pumpWidget(
      TestWidgetWrapper(
        child: MultiBlocProvider(
          providers: [
            BlocProvider<PortfolioBloc>.value(value: portfolio),
            BlocProvider<LocalAssistantBloc>.value(value: fixture.local),
            BlocProvider<RemoteAssistantBloc>.value(value: fixture.remote),
          ],
          child: Scaffold(
            floatingActionButton: AssistantLauncherWidget(
              onLocalSelected: local,
              onRemoteSelected: remote,
            ),
          ),
        ),
      ),
    );
    fixture.start();
    await tester.pumpAndSettle();
  }

  for (final (localFlag, remoteFlag) in [
    (false, false),
    (true, false),
    (false, true),
    (true, true),
  ]) {
    testWidgets(
      'should offer only rolled-out providers when flags are local=$localFlag cloud=$remoteFlag',
      (tester) async {
        final fixture = AssistantTestFixture(
          localRollout: localFlag,
          remoteRollout: remoteFlag,
        );
        var localClicks = 0;
        var remoteClicks = 0;
        await pumpLauncher(
          tester,
          fixture,
          local: () => localClicks++,
          remote: () => remoteClicks++,
        );
        if (!localFlag && !remoteFlag) {
          expect(find.byType(FloatingActionButton), findsNothing);
          return;
        }
        // Neither provider is user-enabled: discovery must still be offered.
        expect(fixture.local.state.isEnabled, isFalse);
        expect(fixture.remote.state.isReady, isFalse);
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();
        if (localFlag && remoteFlag) {
          expect(find.text('Choose an assistant'), findsOneWidget);
          expect(find.text('On-device assistant'), findsOneWidget);
          expect(find.text('Cloud assistant'), findsOneWidget);
          await tester.tap(find.text('Cloud assistant'));
          await tester.pumpAndSettle();
          expect(remoteClicks, 1);
          expect(localClicks, 0);
        } else {
          expect(find.text('Choose an assistant'), findsNothing);
          expect(localClicks, localFlag ? 1 : 0);
          expect(remoteClicks, remoteFlag ? 1 : 0);
        }
      },
    );
  }

  testWidgets(
    'should hide local discovery when injected platform availability represents web',
    (tester) async {
      final fixture = AssistantTestFixture(
        localSupported: false,
        remoteRollout: false,
      );
      await pumpLauncher(tester, fixture, local: () {}, remote: () {});
      expect(find.byType(FloatingActionButton), findsNothing);
      expect(fixture.local.state.status, isA<LocalAssistantUnavailable>());
    },
  );

  testWidgets('should update discovery without polling when dev flags change', (
    tester,
  ) async {
    final fixture = AssistantTestFixture(
      localRollout: false,
      remoteRollout: false,
    );
    await pumpLauncher(tester, fixture, local: () {}, remote: () {});
    expect(find.byType(FloatingActionButton), findsNothing);
    fixture.setRollout(local: true, remote: true, notify: true);
    await tester.pumpAndSettle();
    expect(find.byType(FloatingActionButton), findsOneWidget);
    fixture.setRollout(local: false, remote: false, notify: true);
    await tester.pumpAndSettle();
    expect(find.byType(FloatingActionButton), findsNothing);
  });
}
