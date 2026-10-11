import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/remote_assistant/domain/_domain.dart';
import 'package:portrai/src/feature/remote_assistant/presentation/screen/remote_assistant/bloc/_bloc.dart';
import 'package:portrai/src/feature/remote_assistant/remote_assistant.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:use_case/use_case.dart';

import '../../../../../../../util/assistant_test_fixture.dart';
import '../../../../../../../util/test_wrapper_widget.dart';

void main() {
  setUpAll(AssistantTestFixture.registerFallbacks);
  setUp(() => appServiceLocator.reset());
  tearDown(() => appServiceLocator.reset());

  testWidgets(
    'should invalidate pending output without exposing a bloc when the host becomes visible with rollout off',
    (tester) async {
      final fixture = AssistantTestFixture()..install();
      fixture.remote.add(const RemoteAssistantStartedEvent());
      await tester.pumpWidget(
        const TestWidgetWrapper(
          child: RemoteAssistantVisibilityWidget(child: SizedBox.shrink()),
        ),
      );
      await tester.pumpAndSettle();
      final completion = Completer<Either<RemoteAssistantFailure, void>>();
      late AskRemotePortfolioQuestionParams request;
      when(() => fixture.askRemote(any())).thenAnswer((invocation) {
        request =
            invocation.positionalArguments.single
                as AskRemotePortfolioQuestionParams;
        request.onDelta('Partial');
        return completion.future;
      });
      fixture.remote.add(
        const SendRemoteAssistantQuestionClickEvent('Question'),
      );
      await tester.pump();
      expect(fixture.remote.state.partialAnswer, 'Partial');
      await tester.pumpWidget(const SizedBox.shrink());
      fixture.setRollout(local: true, remote: false);
      await tester.pumpWidget(
        const TestWidgetWrapper(
          child: RemoteAssistantVisibilityWidget(child: SizedBox.shrink()),
        ),
      );
      await tester.pumpAndSettle();
      request.onDelta('Late output');
      completion.complete(const Right(null));
      await tester.pumpAndSettle();
      expect(fixture.remote.state.status, RemoteAssistantStatus.unavailable);
      expect(fixture.remote.state.messages, isEmpty);
      expect(fixture.remote.state.partialAnswer, isEmpty);
      verify(() => fixture.resetRemote()).called(1);
    },
  );

  test(
    'should track cloud views only when the cloud screen is opened',
    () async {
      final fixture = AssistantTestFixture();
      fixture.remote.add(const RemoteAssistantInitializedEvent());
      await pumpEventQueue();
      verifyNever(() => fixture.remoteTracking.trackScreenView());
      fixture.remote.add(const RemoteAssistantStartedEvent());
      await pumpEventQueue();
      verify(() => fixture.remoteTracking.trackScreenView()).called(1);
    },
  );

  testWidgets(
    'should block chat on a direct route when the platform is unsupported',
    (tester) async {
      final fixture = AssistantTestFixture(remoteSupported: false);
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: BlocProvider.value(
            value: fixture.remote,
            child: const RemoteAssistantScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      verifyNever(() => fixture.askRemote(any()));
      expect(fixture.remote.state.status, RemoteAssistantStatus.unavailable);
    },
  );

  for (final action in ['flag off', 'reset']) {
    test(
      'should discard deltas and clear remote state when $action occurs during streaming',
      () async {
        final fixture = AssistantTestFixture();
        fixture.start();
        await pumpEventQueue();
        final completion = Completer<Either<RemoteAssistantFailure, void>>();
        late AskRemotePortfolioQuestionParams request;
        when(() => fixture.askRemote(any())).thenAnswer((invocation) {
          request =
              invocation.positionalArguments.single
                  as AskRemotePortfolioQuestionParams;
          request.onDelta('Partial');
          return completion.future;
        });
        fixture.remote.add(
          const SendRemoteAssistantQuestionClickEvent('Question'),
        );
        await pumpEventQueue();
        expect(fixture.remote.state.partialAnswer, 'Partial');
        if (action == 'flag off') {
          fixture.setRollout(local: true, remote: false);
          fixture.remote.add(const RemoteAssistantInitializedEvent());
        } else {
          fixture.remote.add(const ResetRemoteAssistantClickEvent());
        }
        await pumpEventQueue();
        request.onDelta('Late delta');
        await pumpEventQueue();
        completion.complete(const Right(null));
        await pumpEventQueue();
        expect(fixture.remote.state.messages, isEmpty);
        expect(fixture.remote.state.partialAnswer, isEmpty);
        expect(fixture.remote.state.isSendingQuestion, isFalse);
        expect(
          fixture.remote.state.status,
          action == 'flag off'
              ? RemoteAssistantStatus.unavailable
              : RemoteAssistantStatus.ready,
        );
        if (action == 'reset') {
          verify(() => fixture.resetRemote()).called(1);
        }
      },
    );
  }

  test(
    'should reject new remote requests when rollout is off after startup',
    () async {
      final fixture = AssistantTestFixture();
      fixture.start();
      await pumpEventQueue();
      fixture.setRollout(local: true, remote: false);
      fixture.remote.add(
        const SendRemoteAssistantQuestionClickEvent('Question'),
      );
      await pumpEventQueue();
      expect(fixture.remote.state.status, RemoteAssistantStatus.unavailable);
      verifyNever(() => fixture.askRemote(any()));
    },
  );
}
