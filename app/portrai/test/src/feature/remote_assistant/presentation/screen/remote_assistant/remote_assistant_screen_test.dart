import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:firebase/firebase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/remote_assistant/domain/_domain.dart';
import 'package:portrai/src/feature/remote_assistant/domain/extension/_extension.dart';
import 'package:portrai/src/feature/remote_assistant/presentation/screen/remote_assistant/bloc/_bloc.dart';
import 'package:portrai/src/feature/remote_assistant/presentation/screen/remote_assistant/widget/content_widget.dart';
import 'package:portrai/src/feature/remote_assistant/remote_assistant.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:use_case/use_case.dart';

import '../../../../../../mock/feature/remote_assistant/presentation/screen/remote_assistant/bloc/mock_remote_assistant_bloc.dart';
import '../../../../../../util/assistant_test_fixture.dart';
import '../../../../../../util/test_wrapper_widget.dart';

void main() {
  setUpAll(AssistantTestFixture.registerFallbacks);

  for (final locale in AppLocalizations.supportedLocales) {
    for (final path in ['unavailable', 'context retry', 'conversation']) {
      for (final serviceMessage in [
        'Your credits are depleted. Enable billing to continue.',
        null,
        '   ',
      ]) {
        testWidgets(
          'should show localized fallback and only explicit service details when $path fails in ${locale.languageCode} with details=$serviceMessage',
          (tester) async {
            final failure = serviceMessage == null
                ? AiSdkException(
                    StateError('secret response and prompt'),
                    StackTrace.current,
                  ).toRemoteAssistantFailure()
                : AiServerException(
                    StateError('secret raw SDK body'),
                    StackTrace.current,
                    serviceMessage: serviceMessage,
                  ).toRemoteAssistantFailure();
            final bloc = MockRemoteAssistantBloc()
              ..stubState(
                RemoteAssistantState(
                  status: path == 'unavailable'
                      ? RemoteAssistantStatus.unavailable
                      : RemoteAssistantStatus.ready,
                  portfolioContext: path == 'conversation' ? 'Context' : null,
                  failure: failure,
                ),
              );
            addTearDown(bloc.close);
            await tester.pumpWidget(
              TestWidgetWrapper(
                child: Builder(
                  builder: (context) => Localizations.override(
                    context: context,
                    locale: locale,
                    child: BlocProvider<RemoteAssistantBloc>.value(
                      value: bloc,
                      child: const Scaffold(body: ContentWidget()),
                    ),
                  ),
                ),
              ),
            );
            await tester.pumpAndSettle();
            final localizations = await AppLocalizations.delegate.load(locale);
            final heading = localizations.errorRemoteAssistantUnknown;
            final expected =
                serviceMessage == null || serviceMessage.trim().isEmpty
                ? heading
                : localizations.remoteAssistantErrorDetails(
                    heading,
                    serviceMessage,
                  );
            expect(find.text(expected), findsOneWidget);
            expect(find.textContaining('secret'), findsNothing);
            if (path == 'context retry') {
              await tester.tap(find.text(localizations.assistantRetry));
              verify(
                () => bloc.add(const RemoteAssistantStartedEvent()),
              ).called(1);
            }
          },
        );
      }
    }
  }

  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets(
      'should show the shared localized title without disclosure when opened in ${locale.languageCode}',
      (tester) async {
        final fixture = AssistantTestFixture();
        await appServiceLocator.reset();
        addTearDown(appServiceLocator.reset);
        fixture.install();
        await tester.pumpWidget(
          TestWidgetWrapper(
            child: Builder(
              builder: (context) => Localizations.override(
                context: context,
                locale: locale,
                child: const RemoteAssistantScreen(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final localizations = await AppLocalizations.delegate.load(locale);
        expect(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.text(localizations.chatAssistantTitle),
          ),
          findsOneWidget,
        );
        expect(
          find.ancestor(
            of: find.text(localizations.chatAssistantTitle),
            matching: find.byType(DSTextWidget),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.byType(DSIconButtonWidget),
          ),
          findsOneWidget,
        );
        expect(
          find.byTooltip(localizations.chatAssistantClear),
          findsOneWidget,
        );
        expect(find.text(localizations.chatAssistantClear), findsNothing);
        expect(find.text(localizations.remoteAssistantBadge), findsNothing);
        expect(
          find.byTooltip(localizations.remoteAssistantDisclosure),
          findsNothing,
        );
        expect(find.byIcon(Icons.cloud_outlined), findsNothing);
        expect(find.byIcon(Icons.info_outline), findsNothing);
        expect(find.byIcon(Icons.offline_bolt_rounded), findsNothing);
      },
    );
  }

  testWidgets(
    'should clear retained remote chat and discard streaming output when toolbar clear is clicked',
    (tester) async {
      final fixture = AssistantTestFixture();
      await appServiceLocator.reset();
      addTearDown(appServiceLocator.reset);
      fixture.install();
      await tester.pumpWidget(
        const TestWidgetWrapper(child: RemoteAssistantScreen()),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Question');
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Cloud answer'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        const TestWidgetWrapper(child: RemoteAssistantScreen()),
      );
      await tester.pumpAndSettle();
      expect(find.text('Cloud answer'), findsOneWidget);
      final completion = Completer<Either<RemoteAssistantFailure, void>>();
      late AskRemotePortfolioQuestionParams request;
      when(() => fixture.askRemote(any())).thenAnswer((invocation) {
        request =
            invocation.positionalArguments.single
                as AskRemotePortfolioQuestionParams;
        request.onDelta('Pending answer');
        return completion.future;
      });
      await tester.enterText(find.byType(TextField), 'Follow-up');
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Pending answer'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byTooltip('Clear chat'),
        ),
        findsOneWidget,
      );
      await tester.tap(find.byTooltip('Clear chat'));
      await tester.pumpAndSettle();
      request.onDelta('Late answer');
      completion.complete(const Right(null));
      await tester.pumpAndSettle();
      verify(() => fixture.resetRemote()).called(1);
      expect(fixture.remote.state.messages, isEmpty);
      expect(fixture.remote.state.isSendingQuestion, isFalse);
      expect(find.text('Cloud answer'), findsNothing);
      expect(find.text('Pending answer'), findsNothing);
      expect(find.text('Late answer'), findsNothing);
      expect(find.text('Clear chat'), findsNothing);
    },
  );

  testWidgets(
    'should recheck access without owning the session when the route is opened',
    (tester) async {
      final locator = ModuleInjectorController().serviceLocator;
      await locator.reset();
      addTearDown(locator.reset);
      final bloc = MockRemoteAssistantBloc()
        ..stubState(
          const RemoteAssistantState(status: RemoteAssistantStatus.unavailable),
        );
      addTearDown(bloc.close);
      locator.registerSingleton<RemoteAssistantBloc>(() => bloc);
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: Builder(
            builder: (context) =>
                RemoteAssistantModuleRoute.assistant.builder(context, null, {}),
          ),
        ),
      );
      verify(() => bloc.add(const RemoteAssistantStartedEvent())).called(1);
      expect(find.text('Chat Assistant'), findsOneWidget);
      await tester.tap(find.byTooltip('Clear chat'));
      verify(() => bloc.add(const ResetRemoteAssistantClickEvent())).called(1);
      await tester.pumpWidget(const SizedBox.shrink());
      verifyNever(bloc.close);
    },
  );
}
