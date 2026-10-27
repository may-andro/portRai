import 'dart:math';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/developer_mode/domain/_domain.dart';
import 'package:portrai/src/feature/developer_mode/presentation/extension/_extension.dart';
import 'package:portrai/src/feature/developer_mode/presentation/screen/tracking_events/bloc/_bloc.dart';
import 'package:portrai/src/widget/page_app_bar_widget.dart';
import 'package:portrai/src/widget/screen_content_widget.dart';

part 'details_widget.dart';
part 'filter_widget.dart';
part 'status_widget.dart';
part 'timeline_entry_widget.dart';

class ContentWidget extends StatelessWidget {
  const ContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenContentWidget<TrackingEventsBloc, TrackingEventsState>(
      impressionPrefix: 'tracking_events',
      buildWhen: (previous, current) => previous != current,
      contentOf: (state) => switch (state) {
        TrackingEventsLoadingState() => const ScreenLoadingContent(),
        TrackingEventsErrorState(:final failure) => ScreenErrorContent(
          failure,
          onRetry: () =>
              context.bloc.add(const TrackingEventsRefreshClickEvent()),
        ),
        final TrackingEventsLoadedState loadedState => _loadedContentOf(
          context,
          loadedState,
        ),
      },
      onContentVisible: (content) =>
          context.bloc.add(ViewStateVisibleEvent(content.trackingLabel)),
    );
  }

  ScreenLoadedContent _loadedContentOf(
    BuildContext context,
    TrackingEventsLoadedState state,
  ) {
    final visibleTrackingEvents = state.visibleTrackingEvents;
    return ScreenLoadedContent.slivers([
      PageAppBarWidget(
        title: context.localizations.trackingEventsTitle,
        actions: [
          DSIconButtonWidget(
            Icons.refresh,
            iconColor: context.colorPalette.inverseSurface,
            buttonColor: context.colorPalette.background,
            onPressed: () =>
                context.bloc.add(const TrackingEventsRefreshClickEvent()),
          ),
          const DSHorizontalSpacerWidget(1),
        ],
      ),
      SliverPadding(
        padding: context.screenHorizontalPadding.copyWith(
          top: context.space(factor: 2),
          bottom: context.space(factor: 2),
        ),
        sliver: SliverMainAxisGroup(
          slivers: [
            if (state.trackingEvents.isEmpty)
              const SliverToBoxAdapter(child: _EmptyWidget())
            else ...[
              SliverToBoxAdapter(child: _FilterWidget(state: state)),
              if (visibleTrackingEvents.isEmpty)
                const SliverToBoxAdapter(child: _NoResultsWidget())
              else if (!context.isDesktop)
                _TimelineWidget(state: state)
              else
                SliverCrossAxisGroup(
                  slivers: [
                    SliverCrossAxisExpanded(
                      flex: 3,
                      sliver: _TimelineWidget(state: state),
                    ),
                    SliverConstrainedCrossAxis(
                      maxExtent: context.space(factor: 2),
                      sliver: const SliverToBoxAdapter(),
                    ),
                    SliverCrossAxisExpanded(
                      flex: 2,
                      // Stays in view while the timeline scrolls.
                      sliver: SliverLayoutBuilder(
                        builder: (context, constraints) => PinnedHeaderSliver(
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: min(
                                constraints.scrollOffset,
                                constraints.overlap,
                              ),
                            ),
                            child: _DetailsPanelWidget(
                              trackingEvent: state.selectedTrackingEvent,
                              height: _detailsPanelHeightOf(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ],
        ),
      ),
    ]);
  }

  /// Tall enough to fill the screen below the pinned app bar.
  double _detailsPanelHeightOf(BuildContext context) =>
      MediaQuery.sizeOf(context).height -
      kToolbarHeight -
      context.space(factor: 4);
}

/// The shown events as a timeline, oldest first.
class _TimelineWidget extends StatelessWidget {
  const _TimelineWidget({required this.state});

  final TrackingEventsLoadedState state;

  @override
  Widget build(BuildContext context) {
    final visibleTrackingEvents = state.visibleTrackingEvents;
    return SliverList.builder(
      itemCount: visibleTrackingEvents.length,
      itemBuilder: (context, index) {
        final trackingEvent = visibleTrackingEvents[index];
        return _TimelineEntryWidget(
          trackingEvent: trackingEvent,
          previousTrackingEvent: index == 0
              ? null
              : visibleTrackingEvents[index - 1],
          isLast: index == visibleTrackingEvents.length - 1,
          isSelected: trackingEvent.id == state.selectedTrackingEventId,
        );
      },
    );
  }
}
