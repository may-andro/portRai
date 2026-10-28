part of 'content_widget.dart';

/// One request: a calendar tile with its day, the time and topic, the
/// visitor and their message, and, while it can be answered, the buttons to
/// accept or decline it. A strip in the state's color runs down its side.
class _RequestCardWidget extends StatelessWidget {
  const _RequestCardWidget({
    required this.request,
    required this.now,
    this.isAnswerable = false,
    this.isDeciding = false,
    super.key,
  });

  final ReceivedAppointmentRequestEntity request;
  final DateTime now;
  final bool isAnswerable;
  final bool isDeciding;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final tone = _RequestTone.of(context, request, now);
    final radius = BorderRadius.circular(24);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface.surfaceContainerLow.color,
        borderRadius: radius,
        border: Border.all(color: palette.outline.outlineVariant.color),
        boxShadow: [
          BoxShadow(
            color: palette.utility.shadow.color.withAlpha(
              isAnswerable ? 26 : 12,
            ),
            blurRadius: isAnswerable ? 20 : 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ColoredBox(
                color: tone.accent.color,
                child: const SizedBox(width: 6),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(context.space(factor: 2.5)),
                  child: _CardBodyWidget(
                    request: request,
                    now: now,
                    tone: tone,
                    isAnswerable: isAnswerable,
                    isDeciding: isDeciding,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardBodyWidget extends StatelessWidget {
  const _CardBodyWidget({
    required this.request,
    required this.now,
    required this.tone,
    required this.isAnswerable,
    required this.isDeciding,
  });

  final ReceivedAppointmentRequestEntity request;
  final DateTime now;
  final _RequestTone tone;
  final bool isAnswerable;
  final bool isDeciding;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final localizations = context.localizations;
    final locale = Localizations.localeOf(context).toString();
    final time = localizations.appointmentRequestTimeRange(
      request.slotStart.formattedAppointmentTime(context),
      request.slotEnd.formattedAppointmentTime(context),
    );
    final relativeDay = _relativeDayOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: context.space(factor: 2),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: context.space(factor: 2),
          children: [
            _DateTileWidget(day: request.slotStart.toLocal(), tone: tone),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: context.space(factor: 0.5),
                children: [
                  Wrap(
                    spacing: context.space(),
                    runSpacing: context.space(factor: 0.5),
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      DSTextWidget(
                        time,
                        style: context.typography.emphasizedTitleLarge,
                        color: palette.neutral.grey10,
                      ),
                      if (relativeDay != null)
                        DSTextWidget(
                          relativeDay,
                          style: context.typography.emphasizedLabelMedium,
                          color: palette.brand.primary,
                        ),
                    ],
                  ),
                  DSTextWidget(
                    request.topic,
                    style: context.typography.titleSmall,
                    color: palette.neutral.grey8,
                  ),
                  if (context.isMobile) _TonePillWidget(tone: tone),
                ],
              ),
            ),
            if (!context.isMobile) _TonePillWidget(tone: tone),
          ],
        ),
        Row(
          spacing: context.space(factor: 1.5),
          children: [
            _InitialsAvatarWidget(name: request.name),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DSTextWidget(
                    request.name,
                    style: context.typography.emphasizedTitleMedium,
                    color: palette.neutral.grey10,
                  ),
                  DSTextWidget(
                    request.email,
                    style: context.typography.bodyMedium,
                    color: palette.neutral.grey7,
                  ),
                ],
              ),
            ),
          ],
        ),
        if (request.message.isNotEmpty)
          _MessageWidget(message: request.message),
        Wrap(
          spacing: context.space(),
          runSpacing: context.space(),
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            DSTextWidget(
              localizations.appointmentRequestReceivedOn(
                DateFormat.yMMMd(locale).format(request.createdAt.toLocal()),
              ),
              style: context.typography.labelMedium,
              color: palette.neutral.grey6,
            ),
            if (isAnswerable)
              Wrap(
                spacing: context.space(),
                runSpacing: context.space(),
                children: [
                  DSButtonWidget(
                    label: localizations.appointmentRequestDecline,
                    icon: Icons.close_rounded,
                    variant: DSButtonVariant.secondary,
                    size: DSButtonSize.small,
                    isExpanded: false,
                    isDisabled: isDeciding,
                    onPressed: () =>
                        _decide(context, AppointmentDecision.decline),
                  ),
                  DSButtonWidget(
                    label: localizations.appointmentRequestAccept,
                    icon: Icons.check_rounded,
                    size: DSButtonSize.small,
                    isExpanded: false,
                    isLoading: isDeciding,
                    isDisabled: isDeciding,
                    onPressed: () =>
                        _decide(context, AppointmentDecision.accept),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }

  /// "Today", "Tomorrow" or "In 3 days" for requests still to come.
  String? _relativeDayOf(BuildContext context) {
    if (!request.slotStart.isAfter(now)) return null;
    final localizations = context.localizations;
    final days = appointmentDayOf(
      request.slotStart,
    ).difference(appointmentDayOf(now)).inDays;
    return switch (days) {
      0 => localizations.appointmentRequestToday,
      1 => localizations.appointmentRequestTomorrow,
      _ => localizations.appointmentRequestInDays(days),
    };
  }

  /// Asks first, since the visitor gets an email with the answer.
  Future<void> _decide(
    BuildContext context,
    AppointmentDecision decision,
  ) async {
    final bloc = context.bloc;
    final isConfirmed = await showDialog<bool>(
      context: context,
      builder: (_) =>
          _DecisionDialogWidget(name: request.name, decision: decision),
    );
    if (isConfirmed != true) return;
    bloc.add(
      AppointmentRequestDecisionClickEvent(
        requestId: request.id,
        decision: decision,
      ),
    );
  }
}

/// The day as a small calendar page: the weekday, the date and the month.
class _DateTileWidget extends StatelessWidget {
  const _DateTileWidget({required this.day, required this.tone});

  final DateTime day;
  final _RequestTone tone;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    return Container(
      width: 68,
      padding: EdgeInsets.symmetric(vertical: context.space()),
      decoration: BoxDecoration(
        color: tone.container.color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          DSTextWidget(
            DateFormat.E(locale).format(day).toUpperCase(),
            style: context.typography.emphasizedLabelSmall,
            color: tone.onContainer,
          ),
          DSTextWidget(
            DateFormat.d(locale).format(day),
            style: context.typography.emphasizedHeadlineMedium,
            color: tone.onContainer,
          ),
          DSTextWidget(
            DateFormat.MMM(locale).format(day),
            style: context.typography.labelMedium,
            color: tone.onContainer,
          ),
        ],
      ),
    );
  }
}

class _InitialsAvatarWidget extends StatelessWidget {
  const _InitialsAvatarWidget({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final brand = context.colorPalette.brand;
    final initials = name
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part.characters.first.toUpperCase())
        .join();
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [brand.primary.color, context.colorPalette.accent.color],
        ),
      ),
      child: DSTextWidget(
        initials,
        style: context.typography.emphasizedTitleSmall,
        color: brand.onPrimary,
      ),
    );
  }
}

/// The visitor's message as a quote, cut to a few lines until expanded.
class _MessageWidget extends StatefulWidget {
  const _MessageWidget({required this.message});

  final String message;

  @override
  State<_MessageWidget> createState() => _MessageWidgetState();
}

class _MessageWidgetState extends State<_MessageWidget> {
  static const _collapsedLines = 3;
  static const _longMessageLength = 180;

  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final localizations = context.localizations;
    final isLong = widget.message.length > _longMessageLength;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.space(factor: 1.5)),
      decoration: BoxDecoration(
        color: palette.surface.surfaceContainer.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: context.space(),
            children: [
              Icon(
                Icons.format_quote_rounded,
                size: 20,
                color: palette.brand.primary.color,
              ),
              Expanded(
                child: AnimatedSize(
                  duration: 200.ms,
                  alignment: Alignment.topCenter,
                  child: DSTextWidget(
                    widget.message,
                    maxLines: _isExpanded ? null : _collapsedLines,
                    textOverflow: _isExpanded
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                    style: context.typography.bodyMedium,
                    color: palette.neutral.grey8,
                  ),
                ),
              ),
            ],
          ),
          if (isLong)
            Align(
              alignment: Alignment.centerRight,
              child: DSButtonWidget(
                label: _isExpanded
                    ? localizations.appointmentRequestShowLess
                    : localizations.appointmentRequestShowMore,
                variant: DSButtonVariant.text,
                size: DSButtonSize.small,
                isExpanded: false,
                onPressed: () => setState(() => _isExpanded = !_isExpanded),
              ),
            ),
        ],
      ),
    );
  }
}
