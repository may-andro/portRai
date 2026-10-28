import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/schedule_appointment/domain/_domain.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/extension/_extension.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/screen/appointment_requests/bloc/_bloc.dart';
import 'package:portrai/src/widget/page_chrome_widget.dart';
import 'package:portrai/src/widget/screen_content_widget.dart';

part 'decision_dialog_widget.dart';
part 'empty_widget.dart';
part 'filter_widget.dart';
part 'hero_widget.dart';
part 'request_card_widget.dart';
part 'request_tone.dart';
part 'section_widget.dart';
part 'week_timeline_widget.dart';

/// Widest the page content grows, so cards stay readable on desktop.
const _maxContentWidth = 960.0;

class ContentWidget extends StatelessWidget {
  const ContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenContentWidget<
      AppointmentRequestsBloc,
      AppointmentRequestsState
    >(
      // Searching, filtering and answering replace one loaded state with
      // another.
      buildWhen: (previous, current) => previous != current,
      contentOf: (state) => switch (state) {
        LoadingState() => const ScreenLoadingContent(),
        ErrorState(:final failure) => ScreenErrorContent(
          failure,
          onRetry: () =>
              context.bloc.add(const AppointmentRequestsRetryClickEvent()),
        ),
        final LoadedState state => ScreenLoadedContent.slivers([
          SliverToBoxAdapter(child: _HeroWidget(state: state)),
          SliverToBoxAdapter(
            child: _PageColumnWidget(
              verticalPadding: context.space(factor: 3),
              child: _BodyWidget(state: state),
            ),
          ),
        ]),
      },
    );
  }
}

/// Centers [child] in the page column with the page's side padding.
class _PageColumnWidget extends StatelessWidget {
  const _PageColumnWidget({required this.child, this.verticalPadding = 0});

  final Widget child;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.screenHorizontalPadding.left,
        vertical: verticalPadding,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxContentWidth),
          child: child,
        ),
      ),
    );
  }
}

/// The week, the search and filters, then the requests in their sections.
class _BodyWidget extends StatelessWidget {
  const _BodyWidget({required this.state});

  final LoadedState state;

  @override
  Widget build(BuildContext context) {
    if (state.requests.isEmpty) return const _NoRequestsWidget();

    final localizations = context.localizations;
    final now = DateTime.now();
    final waiting = state.waitingRequests(now);
    final upcoming = state.upcomingRequests(now);
    final earlier = state.earlierRequests(now);
    final isEmpty = waiting.isEmpty && upcoming.isEmpty && earlier.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: context.space(factor: 3),
      children: [
        _WeekTimelineWidget(state: state, now: now),
        _FilterWidget(key: const ValueKey('filter'), state: state, now: now),
        if (isEmpty)
          const _NoResultsWidget()
        else ...[
          if (waiting.isNotEmpty || !state.isNarrowed)
            _SectionWidget(
              title: localizations.appointmentRequestsOpenTitle,
              icon: Icons.mark_email_unread_outlined,
              count: waiting.length,
              tone: _RequestTone.waiting(context),
              emptyChild: const _CaughtUpWidget(),
              children: [
                for (final request in waiting)
                  _RequestCardWidget(
                    key: ValueKey(request.id),
                    request: request,
                    now: now,
                    isAnswerable: true,
                    isDeciding: state.decidingRequestId == request.id,
                  ),
              ],
            ),
          if (upcoming.isNotEmpty)
            _SectionWidget(
              title: localizations.appointmentRequestsUpcomingTitle,
              icon: Icons.event_available_outlined,
              count: upcoming.length,
              tone: _RequestTone.accepted(context),
              children: [
                for (final request in upcoming)
                  _RequestCardWidget(
                    key: ValueKey(request.id),
                    request: request,
                    now: now,
                  ),
              ],
            ),
          if (earlier.isNotEmpty)
            _SectionWidget(
              title: localizations.appointmentRequestsClosedTitle,
              icon: Icons.history_rounded,
              count: earlier.length,
              tone: _RequestTone.unanswered(context),
              children: [
                for (final request in earlier)
                  _RequestCardWidget(
                    key: ValueKey(request.id),
                    request: request,
                    now: now,
                  ),
              ],
            ),
        ],
      ],
    );
  }
}
