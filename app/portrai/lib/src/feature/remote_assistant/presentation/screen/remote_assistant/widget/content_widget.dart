import 'dart:math';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:portrai/src/feature/remote_assistant/presentation/extension/_extension.dart';
import 'package:portrai/src/feature/remote_assistant/presentation/screen/remote_assistant/bloc/_bloc.dart';
import 'package:portrai/src/widget/screen_content_widget.dart';

part 'assistant_genui_surface_widget.dart';

class ContentWidget extends StatelessWidget {
  const ContentWidget({super.key});

  @override
  Widget build(BuildContext context) =>
      ScreenContentWidget<RemoteAssistantBloc, RemoteAssistantState>(
        buildWhen: (previous, current) => previous != current,
        contentOf: (state) => switch (state.status) {
          RemoteAssistantStatus.loading => const ScreenLoadingContent(),
          RemoteAssistantStatus.unavailable => ScreenErrorContent.message(
            state.failure?.remoteAssistantErrorText(context) ??
                context.localizations.errorRemoteAssistantUnavailable,
          ),
          RemoteAssistantStatus.ready => ScreenLoadedContent.fullScreen(
            _ReadyWidget(state: state),
          ),
        },
      );
}

class _ReadyWidget extends StatelessWidget {
  const _ReadyWidget({required this.state});

  final RemoteAssistantState state;

  @override
  Widget build(BuildContext context) {
    final errorText = state.failure?.remoteAssistantErrorText(context);
    return Column(
      children: [
        if (state.isLoadingContext)
          Expanded(
            child: Center(
              child: DSLoadingWidget(
                style: DSLoadingStyle.lottie,
                size: max(context.shortestSide * 0.1, context.space(factor: 2)),
              ),
            ),
          )
        else if (state.portfolioContext == null)
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(context.space()),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DSErrorCardWidget(
                      message:
                          errorText ?? context.localizations.assistantError,
                    ),
                    DSButtonWidget(
                      label: context.localizations.assistantRetry,
                      onPressed: () =>
                          context.bloc.add(const RemoteAssistantStartedEvent()),
                      variant: DSButtonVariant.secondary,
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
              suggestions: state.userRole.assistantSuggestions(context),
              onSubmit: (question) => context.bloc.add(
                SendRemoteAssistantQuestionClickEvent(question),
              ),
              messageContentBuilder: (context, message, index) {
                final surfaces = state.genuiSurfaces
                    .where((surface) => surface.messageIndex == index)
                    .toList();
                if (message.isUser || surfaces.isEmpty) return null;
                final text = switch (message.content) {
                  AssistantTextResponseEntity(:final text) => text.trim(),
                };
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (text.isNotEmpty)
                      DSTextWidget(
                        text,
                        color: context.colorPalette.surface.onSurface,
                        style: context.typography.bodyMedium,
                      ),
                    for (final surface in surfaces)
                      _AssistantGenuiSurfaceWidget(
                        key: ValueKey((
                          surface.genuiController,
                          surface.surfaceId,
                        )),
                        genuiController: surface.genuiController,
                        surfaceId: surface.surfaceId,
                      ),
                  ],
                );
              },
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
  }
}
