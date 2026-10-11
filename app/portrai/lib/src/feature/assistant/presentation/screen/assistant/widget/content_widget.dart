import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/assistant/presentation/screen/assistant/bloc/_bloc.dart';
import 'package:portrai/src/feature/assistant/presentation/widget/assistant_conversation_widget.dart';

part 'model_setup_widget.dart';

class ContentWidget extends StatelessWidget {
  const ContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AssistantBloc, AssistantState>(
      builder: (context, state) {
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
        if (!state.isReady) return _ModelSetupWidget(state: state);
        return AssistantConversationWidget(
          messages: state.messages,
          isSendingQuestion: state.isSendingQuestion,
          errorText: state.hasError
              ? context.localizations.assistantError
              : null,
          onSubmit: (question) =>
              context.bloc.add(SendAssistantQuestionClickEvent(question)),
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
            ],
          ),
        );
      },
    );
  }
}
