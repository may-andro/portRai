import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';

import '../../../../../util/test_wrapper_widget.dart';

void main() {
  testWidgets(
    'should show suggestions without a header when none is supplied',
    (tester) async {
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: AssistantConversationWidget(
            messages: const [],
            isSendingQuestion: false,
            onSubmit: (_) {},
          ),
        ),
      );
      expect(find.text('Which projects use Flutter?'), findsOneWidget);
      expect(
        tester
            .widget<AssistantConversationWidget>(
              find.byType(AssistantConversationWidget),
            )
            .header,
        isNull,
      );
    },
  );

  Future<void> pumpConversation(
    WidgetTester tester, {
    List<AssistantMessageEntity> messages = const [],
    bool isSendingQuestion = false,
    String? errorText,
    ValueChanged<String>? onSubmit,
  }) async {
    await tester.pumpWidget(
      TestWidgetWrapper(
        child: AssistantConversationWidget(
          messages: messages,
          isSendingQuestion: isSendingQuestion,
          header: const Text('Provider identity'),
          errorText: errorText,
          onSubmit: onSubmit ?? (_) {},
        ),
      ),
    );
  }

  testWidgets('should show suggestions and the supplied header when empty', (
    tester,
  ) async {
    await pumpConversation(tester);

    expect(find.text('Provider identity'), findsOneWidget);
    expect(find.text('Which projects use Flutter?'), findsOneWidget);
    expect(find.byIcon(Icons.offline_bolt_rounded), findsNothing);
  });

  testWidgets('should submit a suggestion when it is selected', (tester) async {
    final questions = <String>[];
    await pumpConversation(tester, onSubmit: questions.add);

    await tester.tap(find.text('Which projects use Flutter?'));

    expect(questions, ['Which projects use Flutter?']);
  });

  testWidgets('should submit and clear input when send is clicked', (
    tester,
  ) async {
    final questions = <String>[];
    await pumpConversation(tester, onSubmit: questions.add);
    await tester.enterText(find.byType(TextField), 'My question');

    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pump();

    expect(questions, ['My question']);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '',
    );
  });

  testWidgets('should submit input when the keyboard send action is used', (
    tester,
  ) async {
    final questions = <String>[];
    await pumpConversation(tester, onSubmit: questions.add);
    await tester.enterText(find.byType(TextField), 'Keyboard question');

    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pump();

    expect(questions, ['Keyboard question']);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '',
    );
  });

  testWidgets('should not submit input when it contains only whitespace', (
    tester,
  ) async {
    final questions = <String>[];
    await pumpConversation(tester, onSubmit: questions.add);
    await tester.enterText(find.byType(TextField), '   ');

    await tester.tap(find.byIcon(Icons.send_rounded));

    expect(questions, isEmpty);
  });

  testWidgets('should disable submission when an answer is pending', (
    tester,
  ) async {
    final questions = <String>[];
    await pumpConversation(
      tester,
      isSendingQuestion: true,
      onSubmit: questions.add,
    );

    await tester.tap(find.text('Which projects use Flutter?'));
    await tester.tap(find.byIcon(Icons.send_rounded));

    expect(questions, isEmpty);
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
  });

  testWidgets(
    'should render both roles and an error when messages are supplied',
    (tester) async {
      await pumpConversation(
        tester,
        messages: const [
          AssistantMessageEntity(
            content: AssistantTextResponseEntity(text: 'Question'),
            isUser: true,
          ),
          AssistantMessageEntity(
            content: AssistantTextResponseEntity(text: 'Answer'),
            isUser: false,
          ),
        ],
        errorText: 'Unable to answer',
      );

      expect(find.text('Question'), findsOneWidget);
      expect(find.text('Answer'), findsOneWidget);
      expect(find.text('Unable to answer'), findsOneWidget);
      for (final text in ['Question', 'Answer', 'Unable to answer']) {
        expect(
          find.ancestor(
            of: find.text(text),
            matching: find.byType(DSTextWidget),
          ),
          findsOneWidget,
        );
      }
      expect(find.text('Which projects use Flutter?'), findsNothing);
    },
  );

  testWidgets(
    'should show an answer indicator when a submitted question is pending',
    (tester) async {
      await pumpConversation(
        tester,
        messages: const [
          AssistantMessageEntity(
            content: AssistantTextResponseEntity(text: 'Question'),
            isUser: true,
          ),
        ],
        isSendingQuestion: true,
      );

      expect(find.byType(DSLoadingWidget), findsOneWidget);
      expect(find.text('Question'), findsOneWidget);
    },
  );

  testWidgets(
    'should render updated text when a response changes in place in the conversation',
    (tester) async {
      const question = AssistantMessageEntity(
        content: AssistantTextResponseEntity(text: 'Question'),
        isUser: true,
      );
      await pumpConversation(
        tester,
        messages: const [
          question,
          AssistantMessageEntity(
            content: AssistantTextResponseEntity(text: 'Partial'),
            isUser: false,
          ),
        ],
      );

      await pumpConversation(
        tester,
        messages: const [
          question,
          AssistantMessageEntity(
            content: AssistantTextResponseEntity(text: 'Complete answer'),
            isUser: false,
          ),
        ],
      );
      await tester.pumpAndSettle();

      expect(find.text('Partial'), findsNothing);
      expect(find.text('Complete answer'), findsOneWidget);
    },
  );
}
