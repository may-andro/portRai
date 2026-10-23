import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/generated/failure_translator.g.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:portrai/src/feature/local_assistant/presentation/screen/local_assistant/bloc/_bloc.dart';
import 'package:portrai/src/feature/local_assistant/presentation/widget/local_assistant_card_widget.dart';
import 'package:portrai/src/widget/screen_content_widget.dart';

part 'model_setup_widget.dart';

class ContentWidget extends StatelessWidget {
  const ContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenContentWidget<LocalAssistantBloc, LocalAssistantState>(
      buildWhen: (previous, current) => previous != current,
      contentOf: (state) => _contentOf(context, state),
    );
  }

  ScreenContent _contentOf(BuildContext context, LocalAssistantState state) {
    void retry() => context.bloc.add(const LocalAssistantStartedEvent());
    if (!state.isAvailable) {
      final failure = state.failure;
      return failure == null
          ? ScreenErrorContent.message(
              context.localizations.errorLocalAssistantUnavailable,
            )
          : ScreenErrorContent(failure, onRetry: retry);
    }
    if (state.isLoadingContext) return const ScreenLoadingContent();
    if (state.hasError && state.portfolioContext == null) {
      return ScreenErrorContent.message(
        context.localizations.assistantError,
        onRetry: retry,
      );
    }
    if (!state.isReady) {
      return ScreenLoadedContent.fullScreen(
        SingleChildScrollView(
          child: Column(
            children: [
              _ModelSetupWidget(state: state),
              const LocalAssistantCardContentWidget(),
            ],
          ),
        ),
      );
    }
    return ScreenLoadedContent.fullScreen(
      AssistantConversationWidget(
        messages: state.visibleMessages,
        isSendingQuestion: state.isSendingQuestion,
        errorText: state.hasError
            ? state.failure == null
                  ? context.localizations.assistantError
                  : FailureTranslator.translate(context, state.failure!)
            : null,
        onSubmit: (question) =>
            context.bloc.add(SendLocalAssistantQuestionClickEvent(question)),
      ),
    );
  }
}
