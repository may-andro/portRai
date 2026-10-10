import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/assistant/presentation/screen/assistant/bloc/_bloc.dart';

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
        return state.isReady
            ? _ChatWidget(state: state)
            : _ModelSetupWidget(state: state);
      },
    );
  }
}

class _ModelSetupWidget extends StatelessWidget {
  const _ModelSetupWidget({required this.state});

  final AssistantState state;

  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    final palette = context.colorPalette;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: EdgeInsets.all(context.space(factor: 3)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DSIconWidget(
                Icons.offline_bolt_rounded,
                color: palette.brand.primary,
                size: DSIconSize.large,
              ),
              const DSVerticalSpacerWidget(2),
              DSTextWidget(
                localizations.assistantOnDeviceTitle,
                color: palette.neutral.grey9,
                style: context.typography.emphasizedHeadlineSmall,
                textAlign: TextAlign.center,
              ),
              const DSVerticalSpacerWidget(1),
              DSTextWidget(
                localizations.assistantOnDeviceDescription,
                color: palette.neutral.grey7,
                style: context.typography.bodyMedium,
                textAlign: TextAlign.center,
              ),
              if (state.status case AssistantDownloading(:final progress)) ...[
                const DSVerticalSpacerWidget(3),
                LinearProgressIndicator(
                  color: palette.brand.primary.color,
                  value: progress == 0 ? null : progress / 100,
                ),
                const DSVerticalSpacerWidget(1),
                DSTextWidget(
                  progress == 0
                      ? localizations.assistantPreparingModel
                      : localizations.assistantDownloadProgress(progress),
                  color: palette.neutral.grey7,
                  style: context.typography.labelMedium,
                ),
              ],
              if (state.hasFailed) ...[
                const DSVerticalSpacerWidget(2),
                DSTextWidget(
                  localizations.assistantModelError,
                  color: palette.semantic.error,
                  style: context.typography.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatWidget extends StatefulWidget {
  const _ChatWidget({required this.state});

  final AssistantState state;

  @override
  State<_ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<_ChatWidget> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void didUpdateWidget(covariant _ChatWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final changed =
        oldWidget.state.messages.length != widget.state.messages.length ||
        oldWidget.state.isSendingQuestion != widget.state.isSendingQuestion;
    if (changed) {
      // Keep the end of a long answer in view once it has been laid out.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_scrollController.hasClients) return;
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    final palette = context.colorPalette;
    final state = widget.state;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.space(factor: 2),
                vertical: context.space(),
              ),
              child: Row(
                children: [
                  DSIconWidget(
                    Icons.offline_bolt_rounded,
                    color: palette.brand.primary,
                    size: DSIconSize.small,
                  ),
                  const DSHorizontalSpacerWidget(1),
                  DSTextWidget(
                    localizations.assistantOnDeviceBadge,
                    color: palette.neutral.grey7,
                    style: context.typography.labelMedium,
                  ),
                ],
              ),
            ),
            Expanded(
              child: state.messages.isEmpty
                  ? _SuggestionsWidget(
                      onSelected: _submit,
                      isBusy: state.isSendingQuestion,
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.all(context.space(factor: 2)),
                      itemCount:
                          state.messages.length +
                          (state.isSendingQuestion ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == state.messages.length) {
                          return const Align(
                            alignment: Alignment.centerLeft,
                            child: DSLoadingWidget(size: 28),
                          );
                        }
                        return _MessageBubble(message: state.messages[index]);
                      },
                    ),
            ),
            if (state.hasError)
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.space(factor: 2),
                ),
                child: DSTextWidget(
                  localizations.assistantError,
                  color: palette.semantic.error,
                  style: context.typography.labelMedium,
                ),
              ),
            Padding(
              padding: EdgeInsets.all(context.space(factor: 2)),
              child: Row(
                children: [
                  Expanded(
                    child: DSTextFieldWidget(
                      controller: _controller,
                      enabled: !state.isSendingQuestion,
                      textInputAction: TextInputAction.send,
                      onFieldSubmitted: _submit,
                      hintText: localizations.assistantInputHint,
                    ),
                  ),
                  const DSHorizontalSpacerWidget(1),
                  DSIconButtonWidget(
                    Icons.send_rounded,
                    iconColor: palette.brand.onPrimary,
                    buttonColor: palette.brand.primary,
                    size: DSIconButtonSize.medium,
                    onPressed: state.isSendingQuestion
                        ? null
                        : () => _submit(_controller.text),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit(String question) {
    if (question.trim().isEmpty) return;
    context.bloc.add(SendAssistantQuestionClickEvent(question));
    _controller.clear();
  }
}

class _SuggestionsWidget extends StatelessWidget {
  const _SuggestionsWidget({required this.onSelected, required this.isBusy});

  final ValueChanged<String> onSelected;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    final suggestions = [
      localizations.assistantSuggestionProjects,
      localizations.assistantSuggestionExperience,
      localizations.assistantSuggestionServices,
      localizations.assistantSuggestionFlutterYears,
      localizations.assistantSuggestionPlayStore,
      localizations.assistantSuggestionLeadership,
    ];
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.space(factor: 3)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DSTextWidget(
              localizations.assistantWelcome,
              color: context.colorPalette.neutral.grey9,
              style: context.typography.emphasizedTitleLarge,
              textAlign: TextAlign.center,
            ),
            const DSVerticalSpacerWidget(2),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: context.space(),
              runSpacing: context.space(),
              children: [
                for (final suggestion in suggestions)
                  GestureDetector(
                    onTap: isBusy ? null : () => onSelected(suggestion),
                    child: DSInfoChipWidget(
                      icon: Icons.auto_awesome,
                      label: suggestion,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final AssistantMessage message;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: context.space(factor: 0.75)),
          child: DSCardWidget(
            backgroundColor: isUser
                ? palette.brand.primaryContainer
                : palette.surface.surfaceContainer,
            radius: context.dimen.radiusLevel3,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.space(factor: 1.75),
                vertical: context.space(factor: 1.25),
              ),
              child: DSTextWidget(
                message.text,
                color: isUser
                    ? palette.brand.onPrimaryContainer
                    : palette.surface.onSurface,
                style: context.typography.bodyMedium,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
