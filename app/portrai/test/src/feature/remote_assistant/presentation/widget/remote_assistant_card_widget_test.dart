import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/remote_assistant/presentation/screen/remote_assistant/bloc/_bloc.dart';
import 'package:portrai/src/feature/remote_assistant/remote_assistant.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';

import '../../../../../util/assistant_test_fixture.dart';
import '../../../../../util/test_wrapper_widget.dart';

void main() {
  setUpAll(AssistantTestFixture.registerFallbacks);
  setUp(() => appServiceLocator.reset());
  tearDown(() => appServiceLocator.reset());

  testWidgets(
    'should own its provider without requesting a model when the informational card appears',
    (tester) async {
      final fixture = AssistantTestFixture()..install();
      await tester.pumpWidget(
        const TestWidgetWrapper(
          child: SingleChildScrollView(child: RemoteAssistantCardWidget()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Cloud AI'), findsOneWidget);
      expect(find.byType(Switch), findsNothing);
      expect(find.text('Ask AI'), findsOneWidget);
      expect(find.text('Clear chat'), findsOneWidget);
      verifyNever(() => fixture.askRemote(any()));
      verifyNever(() => fixture.updateLocal(any()));
    },
  );

  testWidgets(
    'should clear only the remote in-memory session when clear chat is clicked',
    (tester) async {
      final fixture = AssistantTestFixture()..install();
      await tester.pumpWidget(
        const TestWidgetWrapper(
          child: SingleChildScrollView(child: RemoteAssistantCardWidget()),
        ),
      );
      await tester.pumpAndSettle();
      fixture.remote.add(
        const SendRemoteAssistantQuestionClickEvent('Question'),
      );
      await tester.pumpAndSettle();
      expect(fixture.remote.state.messages, hasLength(2));
      await tester.tap(find.text('Clear chat'));
      await tester.pumpAndSettle();
      expect(fixture.remote.state.messages, isEmpty);
      expect(fixture.remote.state.isReady, isTrue);
      verify(() => fixture.resetRemote()).called(1);
      verifyNever(() => fixture.resetLocal());
      verifyNever(() => fixture.updateLocal(any()));
    },
  );
}
