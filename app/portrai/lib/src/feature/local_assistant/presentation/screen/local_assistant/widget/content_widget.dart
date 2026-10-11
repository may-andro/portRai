import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/generated/failure_translator.g.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:portrai/src/feature/local_assistant/presentation/screen/local_assistant/bloc/_bloc.dart';
import 'package:portrai/src/feature/local_assistant/presentation/widget/local_assistant_card_widget.dart';

part 'model_setup_widget.dart';

class ContentWidget extends StatelessWidget {
  const ContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocalAssistantBloc, LocalAssistantState>(
      builder: (context, state) {
        if (!state.isAvailable) {
          return Center(
            child: Text(
              state.failure == null
                  ? context.localizations.errorLocalAssistantUnavailable
                  : FailureTranslator.translate(context, state.failure!),
              textAlign: TextAlign.center,
            ),
          );
        }
        if (state.isLoadingContext) {
          return const DSLoadingWidget(size: 40);
        }
        if (state.hasError && state.portfolioContext == null) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(context.space(factor: 3)),
              child: DSTextWidget(
                context.localizations.assistantError,
                color: context.colorPalette.semantic.error,
                style: context.typography.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        if (!state.isReady) {
          return SingleChildScrollView(
            child: Column(
              children: [
                _ModelSetupWidget(state: state),
                const LocalAssistantCardWidget(),
              ],
            ),
          );
        }
        return AssistantConversationWidget(
          messages: state.messages,
          isSendingQuestion: state.isSendingQuestion,
          errorText: state.hasError
              ? state.failure == null
                    ? context.localizations.assistantError
                    : FailureTranslator.translate(context, state.failure!)
              : null,
          onSubmit: (question) =>
              context.bloc.add(SendLocalAssistantQuestionClickEvent(question)),
          header: Row(
            children: [
              DSIconWidget(
                Icons.offline_bolt_rounded,
                color: context.colorPalette.brand.primary,
                size: DSIconSize.small,
              ),
              const DSHorizontalSpacerWidget(1),
              DSTextWidget(
                context.localizations.assistantOnDeviceBadge,
                color: context.colorPalette.neutral.grey7,
                style: context.typography.labelMedium,
              ),
              TextButton(
                onPressed: () =>
                    context.bloc.add(const ResetLocalAssistantClickEvent()),
                child: Text(context.localizations.remoteAssistantReset),
              ),
            ],
          ),
        );
      },
    );
  }
}
