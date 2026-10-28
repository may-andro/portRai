part of 'content_widget.dart';

/// The title and the week ahead at a glance, over a soft gradient with
/// drifting shapes, with the calendar scene beside it on wide screens.
class _HeroWidget extends StatelessWidget {
  const _HeroWidget({required this.state});

  final LoadedState state;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final isWide = !context.isMobile;
    final illustration = RepaintBoundary(
      child: DSLottieIllustrationWidget(
        illustration: DSLottieIllustration.calendarBooking,
        width: context.space(factor: isWide ? 30 : 22),
      ),
    );
    final copy = _HeroCopyWidget(state: state);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            palette.brand.primaryContainer.color.withAlpha(140),
            palette.accentContainer.color.withAlpha(110),
            palette.background.color,
          ],
          stops: const [0, 0.55, 1],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: DSFloatingShapesBackgroundWidget(
                color: palette.brand.primary.color.withAlpha(46),
                shapeCount: 12,
              ),
            ),
          ),
          PageChromeWidget(
            closeColor: palette.neutral.grey10.color,
            child: _PageColumnWidget(
              verticalPadding: context.space(factor: isWide ? 5 : 3),
              child: isWide
                  ? Row(
                      spacing: context.space(factor: 4),
                      children: [
                        Expanded(child: copy),
                        illustration,
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: context.space(factor: 2),
                      children: [
                        Center(child: illustration),
                        copy,
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCopyWidget extends StatelessWidget {
  const _HeroCopyWidget({required this.state});

  final LoadedState state;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final localizations = context.localizations;
    final now = DateTime.now();
    final waitingCount = state.countOf(AppointmentRequestsFilter.waiting, now);
    final upcoming = state.requests.where(
      (request) =>
          request.status == AppointmentRequestStatus.accepted &&
          request.slotStart.isAfter(now),
    );
    final next = upcoming.firstOrNull;

    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: context.space(factor: 1.5),
          children: [
            Container(
              width: context.space(factor: 5),
              height: 4,
              decoration: BoxDecoration(
                color: palette.accent.color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            DSTextWidget(
              localizations.appointmentRequestsTitle,
              style: context.isMobile
                  ? context.typography.emphasizedHeadlineLarge
                  : context.typography.emphasizedDisplayMedium,
              color: palette.neutral.grey10,
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: context.space(factor: 70)),
              child: DSTextWidget(
                localizations.appointmentRequestsDescription,
                style: context.typography.bodyLarge,
                color: palette.neutral.grey8,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: context.space()),
              child: Wrap(
                spacing: context.space(),
                runSpacing: context.space(),
                children: [
                  _TonePillWidget(
                    tone: _RequestTone.waiting(context),
                    label: localizations.appointmentRequestsWaitingCount(
                      waitingCount,
                    ),
                  ),
                  _TonePillWidget(
                    tone: _RequestTone.accepted(context),
                    label: localizations.appointmentRequestsUpcomingCount(
                      upcoming.length,
                    ),
                  ),
                  if (next != null)
                    _TonePillWidget(
                      tone: _RequestTone.unanswered(context),
                      icon: Icons.schedule_rounded,
                      label: localizations.appointmentRequestsNext(
                        '${next.slotStart.toLocal().formattedAppointmentDay(context)}'
                        ' · ${next.slotStart.formattedAppointmentTime(context)}',
                      ),
                    ),
                ],
              ),
            ),
          ],
        )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.08, curve: Curves.easeOutCubic);
  }
}
