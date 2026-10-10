import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';

import '../../../../../mock/feature/assistant/presentation/screen/assistant/bloc/mock_assistant_bloc.dart';
import '../../../../../util/test_wrapper_widget.dart';

void main() {
  Future<void> pumpButton(WidgetTester tester, AssistantState state) async {
    final bloc = MockAssistantBloc()..stubState(state);
    addTearDown(bloc.close);
    await tester.pumpWidget(
      TestWidgetWrapper(
        child: BlocProvider<AssistantBloc>.value(
          value: bloc,
          child: const AssistantButton(),
        ),
      ),
    );
  }

  testWidgets('should show the button when enabled and the model is ready', (
    tester,
  ) async {
    await pumpButton(
      tester,
      const AssistantState(isEnabled: true, isModelReady: true),
    );

    expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
  });

  testWidgets('should hide the button when the model is downloading', (
    tester,
  ) async {
    await pumpButton(
      tester,
      const AssistantState(
        isEnabled: true,
        isPreparingModel: true,
        downloadProgress: 42,
      ),
    );

    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('should hide the button when the assistant is disabled', (
    tester,
  ) async {
    await pumpButton(tester, const AssistantState(isModelReady: true));

    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('should hide the button when preparation failed', (tester) async {
    await pumpButton(
      tester,
      const AssistantState(isEnabled: true, hasError: true),
    );

    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('should hide the button when the feature flag is off', (
    tester,
  ) async {
    await pumpButton(
      tester,
      const AssistantState(
        isFeatureEnabled: false,
        isEnabled: true,
        isModelReady: true,
      ),
    );

    expect(find.byType(FloatingActionButton), findsNothing);
  });
}
