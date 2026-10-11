import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/local_assistant/local_assistant.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/bloc/_bloc.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/widget/assistant_launcher_widget.dart';
import 'package:portrai/src/feature/remote_assistant/domain/_domain.dart';
import 'package:portrai/src/feature/remote_assistant/remote_assistant.dart';
import 'package:use_case/use_case.dart';

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
              onLocalLaunch: local,
              onRemoteLaunch: remote,
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
      'should launch ${remoteFlag
          ? 'remote'
          : localFlag
          ? 'local'
          : 'neither'} directly when flags are local=$localFlag remote=$remoteFlag',
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
        expect(find.byType(BottomSheet), findsNothing);
        expect(localClicks, localFlag && !remoteFlag ? 1 : 0);
        expect(remoteClicks, remoteFlag ? 1 : 0);
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

  testWidgets(
    'should hide entry without local fallback when remote rollout is on an unsupported platform',
    (tester) async {
      final fixture = AssistantTestFixture(
        localEnabled: true,
        remoteSupported: false,
      );
      await pumpLauncher(tester, fixture, local: () {}, remote: () {});
      expect(find.byType(FloatingActionButton), findsNothing);
      expect(fixture.remote.state.isFeatureEnabled, isTrue);
    },
  );

  testWidgets(
    'should offer remote entry when only remote is supported on web',
    (tester) async {
      final fixture = AssistantTestFixture(localSupported: false);
      var remoteClicks = 0;
      await pumpLauncher(
        tester,
        fixture,
        local: () => fail('Local must not launch'),
        remote: () => remoteClicks++,
      );
      await tester.tap(find.byType(FloatingActionButton));
      expect(remoteClicks, 1);
      expect(find.byType(BottomSheet), findsNothing);
    },
  );

  testWidgets(
    'should still open remote consent without local fallback when remote preference loading fails',
    (tester) async {
      final fixture = AssistantTestFixture(localEnabled: true);
      when(
        () => fixture.getRemote(),
      ).thenAnswer((_) => const Left(RemoteAssistantPreferenceFailure()));
      var remoteClicks = 0;
      await pumpLauncher(
        tester,
        fixture,
        local: () => fail('Local must not launch'),
        remote: () => remoteClicks++,
      );
      expect(fixture.remote.state.isFeatureEnabled, isTrue);
      expect(fixture.remote.state.isReady, isFalse);
      await tester.tap(find.byType(FloatingActionButton));
      expect(remoteClicks, 1);
      expect(find.byType(BottomSheet), findsNothing);
    },
  );

  testWidgets(
    'should refresh discovery when visibility initialization rechecks changed flags',
    (tester) async {
      final fixture = AssistantTestFixture(
        localRollout: false,
        remoteRollout: false,
      );
      await pumpLauncher(tester, fixture, local: () {}, remote: () {});
      expect(find.byType(FloatingActionButton), findsNothing);
      fixture.setRollout(local: true, remote: false);
      fixture.local.add(const LocalAssistantInitializedEvent());
      fixture.remote.add(const RemoteAssistantInitializedEvent());
      await tester.pumpAndSettle();
      expect(find.byType(FloatingActionButton), findsOneWidget);
    },
  );
}
