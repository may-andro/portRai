import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:portrai/src/feature/assistant/presentation/screen/assistant/bloc/assistant_event.dart'
    show AssistantEvent;
import 'package:portrai/src/feature/setting/presentation/screen/setting/widget/assistant_card_widget.dart';

import '../../../../../../../mock/feature/assistant/presentation/screen/assistant/bloc/mock_assistant_bloc.dart';
import '../../../../../../../util/test_wrapper_widget.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(const EnableAssistantClickEvent());
  });

  Future<(MockAssistantBloc, AppLocalizations)> pumpCard(
    WidgetTester tester,
    AssistantState state,
  ) async {
    final bloc = MockAssistantBloc()..stubState(state);
    addTearDown(bloc.close);
    await tester.pumpWidget(
      TestWidgetWrapper(
        child: BlocProvider<AssistantBloc>.value(
          value: bloc,
          child: const SingleChildScrollView(child: AssistantCardWidget()),
        ),
      ),
    );
    return (
      bloc,
      tester.element(find.byType(AssistantCardWidget)).localizations,
    );
  }

  testWidgets('should download only after the user agrees when enabled', (
    tester,
  ) async {
    final (bloc, l10n) = await pumpCard(tester, const AssistantState());

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(find.text(l10n.assistantEnableDialogTitle), findsOneWidget);
    verifyNever(() => bloc.add(any<AssistantEvent>()));

    await tester.tap(find.text(l10n.assistantEnableDialogConfirm));
    await tester.pumpAndSettle();

    verify(() => bloc.add(const EnableAssistantClickEvent())).called(1);
  });

  testWidgets('should enable without asking when the model is kept', (
    tester,
  ) async {
    final (bloc, l10n) = await pumpCard(
      tester,
      const AssistantState(isModelDownloaded: true),
    );

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(find.text(l10n.assistantEnableDialogTitle), findsNothing);
    verify(() => bloc.add(const EnableAssistantClickEvent())).called(1);
  });

  testWidgets('should not download when the user cancels the sheet', (
    tester,
  ) async {
    final (bloc, l10n) = await pumpCard(tester, const AssistantState());

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.assistantCancel));
    await tester.pumpAndSettle();

    verifyNever(() => bloc.add(any<AssistantEvent>()));
  });

  testWidgets('should show progress and cancel the download when preparing', (
    tester,
  ) async {
    final (bloc, l10n) = await pumpCard(
      tester,
      const AssistantState(
        isEnabled: true,
        isPreparingModel: true,
        downloadProgress: 42,
      ),
    );

    expect(find.text(l10n.assistantDownloadProgress(42)), findsOneWidget);
    expect(
      tester
          .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
          .value,
      0.42,
    );

    await tester.tap(find.text(l10n.assistantCancel));

    verify(
      () => bloc.add(const DisableAssistantClickEvent(deleteModel: true)),
    ).called(1);
  });

  testWidgets('should ask to delete the model when a ready assistant is off', (
    tester,
  ) async {
    final (bloc, l10n) = await pumpCard(
      tester,
      const AssistantState(isEnabled: true, isModelReady: true),
    );

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.assistantDisableDialogDelete));
    await tester.pumpAndSettle();

    verify(
      () => bloc.add(const DisableAssistantClickEvent(deleteModel: true)),
    ).called(1);
  });

  testWidgets('should keep the model when the user chooses keep', (
    tester,
  ) async {
    final (bloc, l10n) = await pumpCard(
      tester,
      const AssistantState(isEnabled: true, isModelReady: true),
    );

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.assistantDisableDialogKeep));
    await tester.pumpAndSettle();

    verify(
      () => bloc.add(const DisableAssistantClickEvent(deleteModel: false)),
    ).called(1);
  });
}
