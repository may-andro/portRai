import 'package:bloc_test/bloc_test.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:portrai/src/feature/local_assistant/presentation/screen/local_assistant/bloc/_bloc.dart';
import 'package:portrai/src/feature/local_assistant/presentation/screen/local_assistant/widget/content_widget.dart';
import 'package:use_case/use_case.dart';

import '../../../../../../../mock/feature/local_assistant/presentation/screen/local_assistant/bloc/mock_local_assistant_bloc.dart';
import '../../../../../../../util/test_wrapper_widget.dart';

void main() {
  Future<MockLocalAssistantBloc> pumpContent(
    WidgetTester tester,
    LocalAssistantState state,
  ) async {
    final bloc = MockLocalAssistantBloc()..stubState(state);
    addTearDown(bloc.close);
    await tester.pumpWidget(
      TestWidgetWrapper(
        child: BlocProvider<LocalAssistantBloc>.value(
          value: bloc,
          child: const ContentWidget(),
        ),
      ),
    );
    return bloc;
  }

  testWidgets(
    'should dispatch the local event when shared chat submits input',
    (tester) async {
      final bloc = await pumpContent(
        tester,
        const LocalAssistantState(
          status: LocalAssistantReady(),
          isLoadingContext: false,
          portfolioContext: 'Context',
        ),
      );

      expect(find.byType(AssistantConversationWidget), findsOneWidget);
      expect(find.byIcon(Icons.offline_bolt_rounded), findsNothing);
      expect(find.text('Clear chat'), findsNothing);
      expect(find.byIcon(Icons.delete_outline), findsNothing);
      await tester.enterText(find.byType(TextField), 'Local question');
      await tester.tap(find.byIcon(Icons.send_rounded));

      verify(
        () => bloc.add(
          const SendLocalAssistantQuestionClickEvent('Local question'),
        ),
      ).called(1);
    },
  );

  testWidgets(
    'should retain model setup when the local assistant is not ready',
    (tester) async {
      await pumpContent(
        tester,
        const LocalAssistantState(
          status: LocalAssistantDownloading(42),
          isLoadingContext: false,
        ),
      );

      expect(find.byType(AssistantConversationWidget), findsNothing);
      expect(
        tester
            .widget<LinearProgressIndicator>(
              find.byType(LinearProgressIndicator).first,
            )
            .value,
        0.42,
      );
    },
  );

  testWidgets(
    'should inset the setup card from the screen edges when the local '
    'assistant is not ready',
    (tester) async {
      await pumpContent(
        tester,
        const LocalAssistantState(
          status: LocalAssistantDownloading(42),
          isLoadingContext: false,
        ),
      );

      final card = tester.getRect(find.byType(DSCardWidget));
      final screen = tester.getRect(find.byType(ContentWidget));
      expect(card.left, greaterThan(screen.left));
      expect(card.right, lessThan(screen.right));
    },
  );

  testWidgets('should show the loader when the portfolio context is loading', (
    tester,
  ) async {
    await pumpContent(
      tester,
      const LocalAssistantState(status: LocalAssistantReady()),
    );

    expect(find.byType(DSLoadingWidget), findsOneWidget);
    expect(find.byType(AssistantConversationWidget), findsNothing);
  });

  testWidgets(
    'should show the error card with retry when portfolio context cannot load',
    (tester) async {
      final bloc = await pumpContent(
        tester,
        const LocalAssistantState(isLoadingContext: false, hasError: true),
      );

      expect(find.byType(AssistantConversationWidget), findsNothing);
      expect(find.byType(DSErrorCardWidget), findsOneWidget);
      expect(
        find.text('The assistant could not answer. Please try again.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Retry'));

      verify(() => bloc.add(const LocalAssistantStartedEvent())).called(1);
    },
  );

  testWidgets(
    'should show the unavailable message without retry when the assistant is '
    'unavailable',
    (tester) async {
      await pumpContent(
        tester,
        const LocalAssistantState(
          status: LocalAssistantUnavailable(),
          isLoadingContext: false,
        ),
      );

      expect(find.byType(DSErrorCardWidget), findsOneWidget);
      expect(
        find.text(
          'The on-device assistant is not available on this platform or is '
          'turned off for this app.',
        ),
        findsOneWidget,
      );
      expect(find.text('Retry'), findsNothing);
    },
  );

  testWidgets(
    'should show the error card with retry when availability check fails',
    (tester) async {
      final bloc = await pumpContent(
        tester,
        const LocalAssistantState(
          status: LocalAssistantUnavailable(),
          isLoadingContext: false,
          hasError: true,
          failure: UnknownFailure(),
        ),
      );

      expect(find.byType(DSErrorCardWidget), findsOneWidget);
      await tester.tap(find.text('Retry'));

      verify(() => bloc.add(const LocalAssistantStartedEvent())).called(1);
    },
  );

  testWidgets(
    'should show the model error in setup when the model fails to prepare',
    (tester) async {
      await pumpContent(
        tester,
        const LocalAssistantState(
          status: LocalAssistantFailed(),
          isLoadingContext: false,
          portfolioContext: 'Context',
        ),
      );

      expect(find.byType(DSErrorCardWidget), findsNothing);
      expect(
        find.text(
          'Could not prepare the model. Check your connection and try again.',
        ),
        findsWidgets,
      );
    },
  );

  testWidgets('should rebuild the chat when a new message arrives', (
    tester,
  ) async {
    const readyState = LocalAssistantState(
      status: LocalAssistantReady(),
      isLoadingContext: false,
      portfolioContext: 'Context',
    );
    final bloc = MockLocalAssistantBloc();
    addTearDown(bloc.close);
    whenListen(
      bloc,
      Stream.fromIterable([
        readyState.copyWith(
          messages: const [
            AssistantMessageEntity(
              content: AssistantTextResponseEntity(text: 'New answer'),
              isUser: false,
            ),
          ],
        ),
      ]),
      initialState: readyState,
    );
    await tester.pumpWidget(
      TestWidgetWrapper(
        child: BlocProvider<LocalAssistantBloc>.value(
          value: bloc,
          child: const ContentWidget(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('New answer'), findsOneWidget);
  });
}
