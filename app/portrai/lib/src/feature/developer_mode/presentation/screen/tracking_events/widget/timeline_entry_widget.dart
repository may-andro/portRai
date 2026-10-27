part of 'content_widget.dart';

/// One sent event on the timeline: a node on a vertical line, with the event
/// beside it. Screen views get a larger, filled node and a tinted card, so the
/// events that follow read as happening on that screen. Wider screens show the
/// time in a column before the line. Tapping the event selects it: phones and
/// tablets expand it to show the payload, desktops show it in the side panel.
class _TimelineEntryWidget extends StatelessWidget {
  const _TimelineEntryWidget({
    required this.trackingEvent,
    required this.previousTrackingEvent,
    required this.isLast,
    required this.isSelected,
  });

  final TrackingEventEntity trackingEvent;
  final bool isSelected;

  /// The event shown before this one; `null` for the first.
  final TrackingEventEntity? previousTrackingEvent;
  final bool isLast;

  static const _timeColumnWidth = 112.0;

  @override
  Widget build(BuildContext context) {
    final previousTrackingEvent = this.previousTrackingEvent;
    final elapsed = previousTrackingEvent == null
        ? null
        : trackingEvent.formattedElapsedSince(context, previousTrackingEvent);
    final time = _TimeWidget(
      sentAt: trackingEvent.formattedSentAt,
      elapsed: elapsed,
    );

    final railLeft = context.isMobile
        ? 0.0
        : _timeColumnWidth + context.space();

    // The rail is drawn behind the row so it spans the card's height, whatever
    // the card shows.
    return Stack(
      children: [
        Positioned(
          left: railLeft,
          top: 0,
          bottom: 0,
          width: _RailWidget.railWidth,
          child: _RailWidget(
            trackingEvent: trackingEvent,
            isFirst: previousTrackingEvent == null,
            isLast: isLast,
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!context.isMobile) ...[
              SizedBox(
                width: _timeColumnWidth,
                child: Padding(
                  padding: EdgeInsets.only(top: context.space(factor: 1.5)),
                  child: time,
                ),
              ),
              const DSHorizontalSpacerWidget(1),
            ],
            const SizedBox(width: _RailWidget.railWidth),
            const DSHorizontalSpacerWidget(1),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: context.space(factor: 1.5)),
                child: _EventCardWidget(
                  trackingEvent: trackingEvent,
                  time: context.isMobile ? time : null,
                  isSelected: isSelected,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// The send time and the time since the previous event: stacked in the time
/// column on wider screens, on one line inside the card on phones.
class _TimeWidget extends StatelessWidget {
  const _TimeWidget({required this.sentAt, required this.elapsed});

  final String sentAt;
  final String? elapsed;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final elapsed = this.elapsed;
    final sentAtText = DSTextWidget(
      sentAt,
      style: context.typography.labelMedium,
      color: palette.neutral.grey8,
      maxLines: 1,
      textOverflow: TextOverflow.ellipsis,
    );
    final elapsedText = elapsed == null
        ? null
        : DSTextWidget(
            elapsed,
            style: context.typography.labelSmall,
            color: palette.neutral.grey6,
            maxLines: 1,
            textOverflow: TextOverflow.ellipsis,
          );

    if (context.isMobile) {
      // The time since the previous event moves to the next line when the
      // card is too narrow for both.
      return Wrap(
        spacing: context.space(),
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [sentAtText, ?elapsedText],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [sentAtText, ?elapsedText],
    );
  }
}

/// The vertical line with the event's node. The line stops at the first and
/// the last node.
class _RailWidget extends StatelessWidget {
  const _RailWidget({
    required this.trackingEvent,
    required this.isFirst,
    required this.isLast,
  });

  final TrackingEventEntity trackingEvent;
  final bool isFirst;
  final bool isLast;

  static const railWidth = 32.0;
  static const _lineWidth = 2.0;
  static const _screenViewNodeSize = 32.0;
  static const _eventNodeSize = 14.0;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final lineColor = palette.outline.outlineVariant.color;
    final isScreenView = trackingEvent.isScreenView;
    final nodeSize = isScreenView ? _screenViewNodeSize : _eventNodeSize;
    // Lines up the node's centre with the first line of the card.
    final nodeTop =
        context.space(factor: 1.5) +
        context.getTextHeight(context.typography.emphasizedBodyMedium, 1) / 2 -
        nodeSize / 2;
    final nodeCenter = nodeTop + nodeSize / 2;

    return SizedBox(
      width: railWidth,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          if (!isFirst || !isLast)
            Positioned(
              top: isFirst ? nodeCenter : 0,
              bottom: isLast ? null : 0,
              height: isLast ? nodeCenter : null,
              width: _lineWidth,
              child: ColoredBox(color: lineColor),
            ),
          Positioned(
            top: nodeTop,
            child: isScreenView
                ? Container(
                    width: nodeSize,
                    height: nodeSize,
                    decoration: BoxDecoration(
                      color: palette.brand.primary.color,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      trackingEvent.icon,
                      size: nodeSize * 0.55,
                      color: palette.brand.onPrimary.color,
                    ),
                  )
                : Container(
                    width: nodeSize,
                    height: nodeSize,
                    decoration: BoxDecoration(
                      color: palette.background.color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _nodeColorOf(context).color,
                        width: 3,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  DSColor _nodeColorOf(BuildContext context) {
    final palette = context.colorPalette;
    return switch (trackingEvent.actionType) {
      'click' => palette.accent,
      'setup' => palette.semantic.warning,
      _ => palette.neutral.grey6,
    };
  }
}

/// The event's name, area and other parameters. On phones and tablets a
/// selected event expands to show its payload; desktops outline it while its
/// payload is in the side panel.
class _EventCardWidget extends StatelessWidget {
  const _EventCardWidget({
    required this.trackingEvent,
    required this.time,
    required this.isSelected,
  });

  final TrackingEventEntity trackingEvent;
  final bool isSelected;

  /// Shown above the name on phones, which have no time column.
  final Widget? time;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final isScreenView = trackingEvent.isScreenView;
    final isExpanded = isSelected && !context.isDesktop;

    return DSCardWidget(
      onTap: () => context.bloc.add(TrackingEventClickEvent(trackingEvent.id)),
      backgroundColor: isScreenView
          ? palette.brand.primaryContainer
          : palette.surface.surface,
      elevation: const DSElevation(0),
      radius: const DSRadius(8),
      margin: EdgeInsets.zero,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected || isScreenView
                ? palette.brand.primary.color
                : palette.outline.outlineVariant.color,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(context.space(factor: 1.5)),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.topCenter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: context.space(factor: 1.5),
              children: [
                _EventSummaryWidget(
                  trackingEvent: trackingEvent,
                  time: time,
                  trailingIcon: switch ((context.isDesktop, isExpanded)) {
                    (true, _) => Icons.chevron_right,
                    (false, true) => Icons.expand_less,
                    (false, false) => Icons.expand_more,
                  },
                ),
                if (isExpanded) _PayloadWidget(trackingEvent: trackingEvent),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The first lines of an event card: what was sent and from where.
class _EventSummaryWidget extends StatelessWidget {
  const _EventSummaryWidget({
    required this.trackingEvent,
    required this.time,
    required this.trailingIcon,
  });

  final TrackingEventEntity trackingEvent;
  final Widget? time;
  final IconData trailingIcon;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final isScreenView = trackingEvent.isScreenView;
    final parameterSummary = trackingEvent.parameterSummary;
    final time = this.time;

    return Row(
      spacing: context.space(),
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: context.space(factor: 0.25),
            children: [
              ?time,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: context.space(),
                children: [
                  if (!isScreenView)
                    DSIconWidget(
                      trackingEvent.icon,
                      color: palette.neutral.grey8,
                      size: DSIconSize.small,
                    ),
                  Expanded(
                    child: DSTextWidget(
                      isScreenView ? trackingEvent.area : trackingEvent.name,
                      style: context.typography.emphasizedBodyMedium,
                      color: palette.neutral.grey10,
                      maxLines: 1,
                      textOverflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              DSTextWidget(
                isScreenView ? trackingEvent.name : trackingEvent.area,
                style: context.typography.bodySmall,
                color: palette.neutral.grey8,
                maxLines: 1,
                textOverflow: TextOverflow.ellipsis,
              ),
              if (parameterSummary.isNotEmpty)
                DSTextWidget(
                  parameterSummary,
                  style: context.typography.bodySmall,
                  color: palette.neutral.grey7,
                  maxLines: context.isMobile ? 2 : 1,
                  textOverflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        DSIconWidget(
          trailingIcon,
          color: palette.neutral.grey7,
          size: DSIconSize.medium,
        ),
      ],
    );
  }
}
