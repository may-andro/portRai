import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/assistant/domain/entity/_entity.dart';

part 'message_bubble_widget.dart';
part 'suggestions_widget.dart';

/// Renders a portfolio conversation without owning its provider or lifecycle.
/// The screen supplies optional status feedback/errors and handles submission.
class AssistantConversationWidget extends StatefulWidget {
  const AssistantConversationWidget({
    super.key,
    required this.messages,
    required this.isSendingQuestion,
    this.header,
    required this.onSubmit,
    this.errorText,
    this.messageContentBuilder,
    this.suggestions,
  });

  final List<AssistantMessageEntity> messages;
  final bool isSendingQuestion;
  final Widget? header;
  final ValueChanged<String> onSubmit;
  final String? errorText;

  /// Starter questions shown before the first message; defaults to the
  /// general portfolio questions.
  final List<String>? suggestions;
  final Widget? Function(
    BuildContext context,
    AssistantMessageEntity message,
    int index,
  )?
  messageContentBuilder;

  @override
  State<AssistantConversationWidget> createState() =>
      _AssistantConversationWidgetState();
}

class _AssistantConversationWidgetState
    extends State<AssistantConversationWidget> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void didUpdateWidget(covariant AssistantConversationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final changed =
        oldWidget.messages != widget.messages ||
        oldWidget.isSendingQuestion != widget.isSendingQuestion;
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
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Column(
          children: [
            if (widget.header case final header?)
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.space(factor: 2),
                  vertical: context.space(),
                ),
                child: header,
              ),
            Expanded(
              child: widget.messages.isEmpty
                  ? _SuggestionsWidget(
                      suggestions: widget.suggestions,
                      onSelected: _submit,
                      isBusy: widget.isSendingQuestion,
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.all(context.space(factor: 2)),
                      itemCount:
                          widget.messages.length +
                          (widget.isSendingQuestion ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == widget.messages.length) {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: DSLoadingWidget(
                              style: DSLoadingStyle.lottie,
                              size: context.space(factor: 1.75),
                            ),
                          );
                        }
                        final message = widget.messages[index];
                        return _MessageBubble(
                          message: message,
                          content: widget.messageContentBuilder?.call(
                            context,
                            message,
                            index,
                          ),
                        );
                      },
                    ),
            ),
            if (widget.errorText case final errorText?)
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.space(factor: 2),
                ),
                child: DSTextWidget(
                  errorText,
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
                      enabled: !widget.isSendingQuestion,
                      enabledBorderColor: palette.neutral.grey4,
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
                    onPressed: widget.isSendingQuestion
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
    if (question.trim().isEmpty || widget.isSendingQuestion) return;
    widget.onSubmit(question);
    _controller.clear();
  }
}
