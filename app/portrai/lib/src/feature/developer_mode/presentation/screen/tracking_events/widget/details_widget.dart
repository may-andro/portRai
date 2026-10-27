part of 'content_widget.dart';

/// The side panel on desktops: the selected event's payload, or a hint to
/// select one. Scrolls on its own when taller than [height].
class _DetailsPanelWidget extends StatelessWidget {
  const _DetailsPanelWidget({
    required this.trackingEvent,
    required this.height,
  });

  final TrackingEventEntity? trackingEvent;
  final double height;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final trackingEvent = this.trackingEvent;
    return Padding(
      padding: EdgeInsets.only(bottom: context.space(factor: 1.5)),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: palette.surface.surface.color,
          borderRadius: BorderRadius.circular(context.dimen.radiusLevel3.value),
          border: Border.all(color: palette.outline.outlineVariant.color),
        ),
        clipBehavior: Clip.antiAlias,
        child: trackingEvent == null
            ? Center(
                child: Padding(
                  padding: EdgeInsets.all(context.space(factor: 3)),
                  child: DSTextWidget(
                    context.localizations.trackingEventsSelectHint,
                    style: context.typography.bodyMedium,
                    color: palette.neutral.grey7,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : SingleChildScrollView(
                padding: EdgeInsets.all(context.space(factor: 2)),
                child: _PayloadWidget(trackingEvent: trackingEvent),
              ),
      ),
    );
  }
}

/// The sent parameters as JSON, with a button that copies it.
class _PayloadWidget extends StatelessWidget {
  const _PayloadWidget({required this.trackingEvent});

  final TrackingEventEntity trackingEvent;

  static const _fontFamily = 'monospace';

  Future<void> _copyPayload(BuildContext context) async {
    final copiedMessage = context.localizations.trackingEventPayloadCopied;
    await Clipboard.setData(ClipboardData(text: trackingEvent.payload));
    if (!context.mounted) return;
    context.showSnackBar(snackBar: DSSnackBar(message: copiedMessage));
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: context.space(),
      children: [
        Row(
          children: [
            Expanded(
              child: DSTextWidget(
                context.localizations.trackingEventPayload,
                style: context.typography.emphasizedTitleSmall,
                color: palette.neutral.grey10,
              ),
            ),
            DSButtonWidget(
              label: context.localizations.trackingEventCopyPayload,
              icon: Icons.copy_rounded,
              variant: DSButtonVariant.text,
              size: DSButtonSize.small,
              isExpanded: false,
              onPressed: () => _copyPayload(context),
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.all(context.space(factor: 1.5)),
          decoration: BoxDecoration(
            color: palette.surface.surfaceContainerLow.color,
            borderRadius: BorderRadius.circular(
              context.dimen.radiusLevel2.value,
            ),
          ),
          // Long values scroll sideways instead of wrapping the JSON.
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DSTextWidget(
              trackingEvent.payload,
              style: context.typography.bodySmall,
              color: palette.neutral.grey10,
              fontFamily: _fontFamily,
            ),
          ),
        ),
      ],
    );
  }
}
