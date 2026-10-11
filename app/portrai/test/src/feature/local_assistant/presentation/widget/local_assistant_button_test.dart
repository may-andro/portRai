import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/local_assistant/presentation/screen/local_assistant/bloc/_bloc.dart';
import 'package:portrai/src/feature/local_assistant/presentation/widget/local_assistant_button.dart';

import '../../../../../mock/feature/local_assistant/presentation/screen/local_assistant/bloc/mock_local_assistant_bloc.dart';
import '../../../../../util/test_wrapper_widget.dart';

void main() {
  Future<void> pumpButton(
    WidgetTester tester,
    LocalAssistantState state,
  ) async {
    final bloc = MockLocalAssistantBloc()..stubState(state);
    addTearDown(bloc.close);
    await tester.pumpWidget(
      TestWidgetWrapper(
        child: BlocProvider<LocalAssistantBloc>.value(
          value: bloc,
          child: const LocalAssistantButton(),
        ),
      ),
    );
  }

  testWidgets('should show the button when enabled and the model is ready', (
    tester,
  ) async {
    await pumpButton(
      tester,
      const LocalAssistantState(status: LocalAssistantReady()),
    );

    expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
  });

  testWidgets('should hide the button when the model is downloading', (
    tester,
  ) async {
    await pumpButton(
      tester,
      const LocalAssistantState(status: LocalAssistantDownloading(42)),
    );

    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('should hide the button when the assistant is disabled', (
    tester,
  ) async {
    await pumpButton(tester, const LocalAssistantState());

    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('should hide the button when preparation failed', (tester) async {
    await pumpButton(
      tester,
      const LocalAssistantState(status: LocalAssistantFailed()),
    );

    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('should hide the button when the feature flag is off', (
    tester,
  ) async {
    await pumpButton(
      tester,
      const LocalAssistantState(status: LocalAssistantUnavailable()),
    );

    expect(find.byType(FloatingActionButton), findsNothing);
  });
}
