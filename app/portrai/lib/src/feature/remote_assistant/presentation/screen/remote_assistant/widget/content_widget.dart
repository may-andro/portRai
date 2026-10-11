import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:portrai/src/feature/remote_assistant/presentation/extension/_extension.dart';
import 'package:portrai/src/feature/remote_assistant/presentation/screen/remote_assistant/bloc/_bloc.dart';

class ContentWidget extends StatelessWidget {
  const ContentWidget({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<RemoteAssistantBloc, RemoteAssistantState>(
        builder: (context, state) {
          final failure = state.failure;
          final errorText = failure?.remoteAssistantErrorText(context);
          if (state.status == RemoteAssistantStatus.loading) {
            return const Center(child: DSLoadingWidget(size: 40));
          }
          if (state.status == RemoteAssistantStatus.unavailable) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(context.space(factor: 3)),
                child: DSTextWidget(
                  errorText ??
                      context.localizations.errorRemoteAssistantUnavailable,
                  color: context.colorPalette.textPrimary,
                  style: context.typography.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return Column(
            children: [
              if (state.isLoadingContext)
                const Expanded(child: Center(child: DSLoadingWidget(size: 40)))
              else if (state.portfolioContext == null)
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(context.space(factor: 3)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DSTextWidget(
                            errorText ?? context.localizations.assistantError,
                            color: context.colorPalette.textPrimary,
                            style: context.typography.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                          DSButtonWidget(
                            label: context.localizations.assistantRetry,
                            onPressed: () => context.bloc.add(
                              const RemoteAssistantStartedEvent(),
                            ),
                            variant: DSButtonVariant.text,
                            size: DSButtonSize.small,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: AssistantConversationWidget(
                    messages: state.visibleMessages,
                    isSendingQuestion: state.isSendingQuestion,
                    errorText: errorText,
                    onSubmit: (question) => context.bloc.add(
                      SendRemoteAssistantQuestionClickEvent(question),
                    ),
                    header: state.isSendingQuestion
                        ? DSTextWidget(
                            context.localizations.remoteAssistantGenerating,
                            color: context.colorPalette.textSecondary,
                            style: context.typography.labelMedium,
                            textAlign: TextAlign.center,
                          )
                        : null,
                  ),
                ),
            ],
          );
        },
      );
}
