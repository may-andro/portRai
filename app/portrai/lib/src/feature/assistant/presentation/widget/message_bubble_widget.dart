part of 'assistant_conversation_widget.dart';

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, this.content});

  final AssistantMessageEntity message;
  final Widget? content;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final isUser = message.isUser;
    final text = switch (message.content) {
      AssistantTextResponseEntity(:final text) => text.trim(),
    };
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
              child:
                  content ??
                  DSTextWidget(
                    text,
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
