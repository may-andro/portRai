import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/local_assistant/local_assistant.dart';
import 'package:portrai/src/feature/local_assistant/presentation/screen/local_assistant/bloc/_bloc.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';

import '../../../../../mock/feature/local_assistant/presentation/screen/local_assistant/bloc/mock_local_assistant_bloc.dart';
import '../../../../../util/test_wrapper_widget.dart';

void main() {
  setUp(() => appServiceLocator.reset());
  tearDown(() => appServiceLocator.reset());
  setUpAll(() {
    registerFallbackValue(const EnableLocalAssistantClickEvent());
  });

  Future<(MockLocalAssistantBloc, AppLocalizations)> pumpCard(
    WidgetTester tester,
    LocalAssistantState state,
  ) async {
    final bloc = MockLocalAssistantBloc()..stubState(state);
    appServiceLocator.registerSingleton<LocalAssistantBloc>(() => bloc);
    addTearDown(bloc.close);
    await tester.pumpWidget(
      const TestWidgetWrapper(
        child: SingleChildScrollView(child: LocalAssistantCardWidget()),
      ),
    );
    return (
      bloc,
      tester.element(find.byType(LocalAssistantCardWidget)).localizations,
    );
  }

  testWidgets('should download only after the user agrees when enabled', (
    tester,
  ) async {
    final (bloc, l10n) = await pumpCard(tester, const LocalAssistantState());

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(find.text(l10n.assistantEnableDialogTitle), findsOneWidget);
    verifyNever(() => bloc.add(const EnableLocalAssistantClickEvent()));

    await tester.tap(find.text(l10n.assistantEnableDialogConfirm));
    await tester.pumpAndSettle();

    verify(() => bloc.add(const EnableLocalAssistantClickEvent())).called(1);
  });

  testWidgets('should enable without asking when the model is kept', (
    tester,
  ) async {
    final (bloc, l10n) = await pumpCard(
      tester,
      const LocalAssistantState(isModelDownloaded: true),
    );

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(find.text(l10n.assistantEnableDialogTitle), findsNothing);
    verify(() => bloc.add(const EnableLocalAssistantClickEvent())).called(1);
  });

  testWidgets('should not download when the user cancels the sheet', (
    tester,
  ) async {
    final (bloc, l10n) = await pumpCard(tester, const LocalAssistantState());

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.assistantCancel));
    await tester.pumpAndSettle();

    verifyNever(() => bloc.add(const EnableLocalAssistantClickEvent()));
  });

  testWidgets('should show progress and cancel the download when preparing', (
    tester,
  ) async {
    final (bloc, l10n) = await pumpCard(
      tester,
      const LocalAssistantState(status: LocalAssistantDownloading(42)),
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
      () => bloc.add(const DisableLocalAssistantClickEvent(deleteModel: true)),
    ).called(1);
  });

  testWidgets('should ask to delete the model when a ready assistant is off', (
    tester,
  ) async {
    final (bloc, l10n) = await pumpCard(
      tester,
      const LocalAssistantState(status: LocalAssistantReady()),
    );

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.assistantDisableDialogDelete));
    await tester.pumpAndSettle();

    verify(
      () => bloc.add(const DisableLocalAssistantClickEvent(deleteModel: true)),
    ).called(1);
  });

  testWidgets('should keep the model when the user chooses keep', (
    tester,
  ) async {
    final (bloc, l10n) = await pumpCard(
      tester,
      const LocalAssistantState(status: LocalAssistantReady()),
    );

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.assistantDisableDialogKeep));
    await tester.pumpAndSettle();

    verify(
      () => bloc.add(const DisableLocalAssistantClickEvent(deleteModel: false)),
    ).called(1);
  });
}
