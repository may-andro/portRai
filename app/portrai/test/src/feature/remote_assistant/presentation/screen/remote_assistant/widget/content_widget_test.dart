import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:portrai/src/feature/remote_assistant/presentation/screen/remote_assistant/bloc/_bloc.dart';
import 'package:portrai/src/feature/remote_assistant/presentation/screen/remote_assistant/widget/content_widget.dart';

import '../../../../../../../mock/feature/remote_assistant/presentation/screen/remote_assistant/bloc/mock_remote_assistant_bloc.dart';
import '../../../../../../../util/test_wrapper_widget.dart';

void main() {
  Future<MockRemoteAssistantBloc> pumpContent(
    WidgetTester tester,
    RemoteAssistantState state,
  ) async {
    final bloc = MockRemoteAssistantBloc()..stubState(state);
    addTearDown(bloc.close);
    await tester.pumpWidget(
      TestWidgetWrapper(
        child: BlocProvider<RemoteAssistantBloc>.value(
          value: bloc,
          child: const ContentWidget(),
        ),
      ),
    );
    return bloc;
  }

  testWidgets('should hide chat when the remote rollout is unavailable', (
    tester,
  ) async {
    await pumpContent(
      tester,
      const RemoteAssistantState(status: RemoteAssistantStatus.unavailable),
    );
    expect(find.byType(AssistantConversationWidget), findsNothing);
    expect(find.byType(DSTextWidget), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
  });

  testWidgets('should share chat presentation when remote AI is ready', (
    tester,
  ) async {
    final bloc = await pumpContent(
      tester,
      const RemoteAssistantState(
        status: RemoteAssistantStatus.ready,
        portfolioContext: 'Portfolio',
      ),
    );
    expect(find.byType(AssistantConversationWidget), findsOneWidget);
    expect(find.byIcon(Icons.cloud_outlined), findsNothing);
    expect(find.byIcon(Icons.info_outline), findsNothing);
    expect(find.text('Cloud AI via Firebase and Google'), findsNothing);
    expect(find.text('Clear chat'), findsNothing);
    expect(find.byIcon(Icons.offline_bolt_rounded), findsNothing);
    await tester.enterText(find.byType(TextField), 'Remote question');
    await tester.tap(find.byIcon(Icons.send_rounded));
    verify(
      () => bloc.add(
        const SendRemoteAssistantQuestionClickEvent('Remote question'),
      ),
    ).called(1);
    expect(find.byType(Switch), findsNothing);
  });

  testWidgets('should mark provisional text when an answer is streaming', (
    tester,
  ) async {
    await pumpContent(
      tester,
      const RemoteAssistantState(
        status: RemoteAssistantStatus.ready,
        portfolioContext: 'Portfolio',
        isSendingQuestion: true,
        partialAnswer: 'Partial answer',
      ),
    );
    expect(find.text('Partial answer'), findsOneWidget);
    expect(
      find.ancestor(
        of: find.text('Generating — this answer is not yet complete'),
        matching: find.byType(DSTextWidget),
      ),
      findsOneWidget,
    );
    expect(
      find.text('Generating — this answer is not yet complete'),
      findsOneWidget,
    );
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
  });

  testWidgets('should offer context retry when context loading failed', (
    tester,
  ) async {
    final bloc = await pumpContent(
      tester,
      const RemoteAssistantState(status: RemoteAssistantStatus.ready),
    );
    expect(find.byType(AssistantConversationWidget), findsNothing);
    expect(find.byType(DSButtonWidget), findsOneWidget);
    await tester.tap(find.text('Retry'));
    verify(() => bloc.add(const RemoteAssistantStartedEvent())).called(1);
  });
}
