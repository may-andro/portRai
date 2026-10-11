import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:portrai/src/feature/assistant/presentation/screen/assistant/bloc/assistant_event.dart';
import 'package:portrai/src/feature/assistant/presentation/screen/assistant/widget/content_widget.dart';

import '../../../../../../../mock/feature/assistant/presentation/screen/assistant/bloc/mock_assistant_bloc.dart';
import '../../../../../../../util/test_wrapper_widget.dart';

void main() {
  Future<MockAssistantBloc> pumpContent(
    WidgetTester tester,
    AssistantState state,
  ) async {
    final bloc = MockAssistantBloc()..stubState(state);
    addTearDown(bloc.close);
    await tester.pumpWidget(
      TestWidgetWrapper(
        child: BlocProvider<AssistantBloc>.value(
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
        const AssistantState(
          status: AssistantReady(),
          isLoadingContext: false,
          portfolioContext: 'Context',
        ),
      );

      expect(find.byType(AssistantConversationWidget), findsOneWidget);
      expect(find.byIcon(Icons.offline_bolt_rounded), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Local question');
      await tester.tap(find.byIcon(Icons.send_rounded));

      verify(
        () => bloc.add(const SendAssistantQuestionClickEvent('Local question')),
      ).called(1);
    },
  );

  testWidgets(
    'should retain model setup when the local assistant is not ready',
    (tester) async {
      await pumpContent(
        tester,
        const AssistantState(
          status: AssistantDownloading(42),
          isLoadingContext: false,
        ),
      );

      expect(find.byType(AssistantConversationWidget), findsNothing);
      expect(
        tester
            .widget<LinearProgressIndicator>(
              find.byType(LinearProgressIndicator),
            )
            .value,
        0.42,
      );
    },
  );

  testWidgets(
    'should show the existing error when portfolio context cannot load',
    (tester) async {
      await pumpContent(
        tester,
        const AssistantState(isLoadingContext: false, hasError: true),
      );

      expect(find.byType(AssistantConversationWidget), findsNothing);
      expect(
        find.text('The assistant could not answer. Please try again.'),
        findsOneWidget,
      );
    },
  );
}
