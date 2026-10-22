import 'package:bloc_test/bloc_test.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:portrai/src/feature/remote_assistant/presentation/screen/remote_assistant/bloc/_bloc.dart';
import 'package:portrai/src/feature/remote_assistant/presentation/screen/remote_assistant/widget/content_widget.dart';
import 'package:portrai/src/feature/user/user.dart';

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

  testWidgets('should show the loader when access is being checked', (
    tester,
  ) async {
    await pumpContent(tester, const RemoteAssistantState());
    expect(find.byType(DSLoadingWidget), findsOneWidget);
    expect(find.byType(AssistantConversationWidget), findsNothing);
    expect(find.byType(DSErrorCardWidget), findsNothing);
  });

  testWidgets('should show the error card without chat when the remote '
      'rollout is unavailable', (tester) async {
    await pumpContent(
      tester,
      const RemoteAssistantState(status: RemoteAssistantStatus.unavailable),
    );
    expect(find.byType(AssistantConversationWidget), findsNothing);
    expect(find.byType(DSErrorCardWidget), findsOneWidget);
    expect(find.text('The cloud assistant is not available.'), findsOneWidget);
    expect(find.byType(DSButtonWidget), findsNothing);
  });

  testWidgets('should show the loader without chat when the context is '
      'loading', (tester) async {
    await pumpContent(
      tester,
      const RemoteAssistantState(
        status: RemoteAssistantStatus.ready,
        isLoadingContext: true,
      ),
    );
    expect(find.byType(DSLoadingWidget), findsOneWidget);
    expect(find.byType(AssistantConversationWidget), findsNothing);
  });

  testWidgets('should rebuild the chat when a new message arrives', (
    tester,
  ) async {
    final bloc = MockRemoteAssistantBloc();
    addTearDown(bloc.close);
    const ready = RemoteAssistantState(
      status: RemoteAssistantStatus.ready,
      portfolioContext: 'Portfolio',
    );
    whenListen(
      bloc,
      Stream.value(
        ready.copyWith(
          messages: const [
            AssistantMessageEntity(
              content: AssistantTextResponseEntity(text: 'New answer'),
              isUser: false,
            ),
          ],
        ),
      ),
      initialState: ready,
    );
    await tester.pumpWidget(
      TestWidgetWrapper(
        child: BlocProvider<RemoteAssistantBloc>.value(
          value: bloc,
          child: const ContentWidget(),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('New answer'), findsOneWidget);
  });

  for (final (role, expected, notExpected) in [
    (
      UserRole.developer,
      'Which technologies and tools are used?',
      'Is he available for new work?',
    ),
    (
      UserRole.recruiter,
      'Is he available for new work?',
      'Which technologies and tools are used?',
    ),
    (null, 'Which services are offered?', 'Is he available for new work?'),
  ]) {
    testWidgets('should show matching starter questions when the role is '
        '$role', (tester) async {
      await pumpContent(
        tester,
        RemoteAssistantState(
          status: RemoteAssistantStatus.ready,
          portfolioContext: 'Portfolio',
          userRole: role,
        ),
      );

      expect(find.text(expected), findsOneWidget);
      expect(find.text(notExpected), findsNothing);
    });
  }

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
    expect(find.byType(DSErrorCardWidget), findsOneWidget);
    expect(find.byType(DSButtonWidget), findsOneWidget);
    await tester.tap(find.text('Retry'));
    verify(() => bloc.add(const RemoteAssistantStartedEvent())).called(1);
  });
}
