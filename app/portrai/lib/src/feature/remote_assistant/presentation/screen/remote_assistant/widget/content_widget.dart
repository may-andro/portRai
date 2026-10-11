import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/generated/failure_translator.g.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:portrai/src/feature/remote_assistant/presentation/screen/remote_assistant/bloc/_bloc.dart';

class ContentWidget extends StatelessWidget {
  const ContentWidget({super.key});

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<RemoteAssistantBloc, RemoteAssistantState>(
    builder: (context, state) {
      final failure = state.failure;
      final errorText = failure == null
          ? null
          : FailureTranslator.translate(context, failure);
      if (state.status == RemoteAssistantStatus.loading) {
        return const Center(child: DSLoadingWidget(size: 40));
      }
      if (state.status == RemoteAssistantStatus.unavailable) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(context.space(factor: 3)),
            child: Text(
              errorText ??
                  context.localizations.errorRemoteAssistantUnavailable,
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
      return Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.space(factor: 2)),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: context.space(),
              children: [
                TextButton(
                  onPressed: () =>
                      context.bloc.add(const ResetRemoteAssistantClickEvent()),
                  child: Text(context.localizations.remoteAssistantReset),
                ),
              ],
            ),
          ),
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
                      Text(
                        errorText ?? context.localizations.assistantError,
                        textAlign: TextAlign.center,
                      ),
                      TextButton(
                        onPressed: () => context.bloc.add(
                          const RemoteAssistantStartedEvent(),
                        ),
                        child: Text(context.localizations.assistantRetry),
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
                header: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cloud_outlined, size: 18),
                        const DSHorizontalSpacerWidget(1),
                        Flexible(
                          child: Text(
                            context.localizations.remoteAssistantBadge,
                          ),
                        ),
                        Tooltip(
                          message:
                              context.localizations.remoteAssistantDisclosure,
                          child: const Icon(Icons.info_outline, size: 18),
                        ),
                      ],
                    ),
                    if (state.isSendingQuestion)
                      Text(
                        context.localizations.remoteAssistantGenerating,
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),
            ),
        ],
      );
    },
  );
}
