import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/feature_flag/domain/_domain.dart';
import 'package:portrai/src/feature/feature_flag/presentation/screen/feature_flag/bloc/_bloc.dart';
import 'package:portrai/src/feature/feature_flag/presentation/screen/feature_flag/widget/header_widget.dart';
import 'package:portrai/src/widget/page_app_bar_widget.dart';
import 'package:portrai/src/widget/screen_content_widget.dart';

part 'loaded_content_widget.dart';

part 'grid_widget.dart';

part 'grid_item_widget.dart';

part 'list_widget.dart';

part 'list_item_widget.dart';

part 'empty_search_result_widget.dart';

part 'header_actions_widget.dart';

class ContentWidget extends StatelessWidget {
  const ContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenContentWidget<FeatureFlagBloc, FeatureFlagState>(
      impressionPrefix: 'feature_flag',
      buildWhen: (previous, current) => previous != current,
      contentOf: (state) => switch (state) {
        FeatureFlagInitialState() ||
        FeatureFlagLoadingState() => const ScreenLoadingContent(),
        final FeatureFlagLoadedState state when state.filteredFlags.isEmpty =>
          ScreenLoadedContent.slivers([
            ..._headerSlivers(context, state),
            SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptySearchResultWidget(searchQuery: state.searchQuery),
            ),
          ]),
        final FeatureFlagLoadedState state => ScreenLoadedContent.slivers([
          ..._headerSlivers(context, state),
          _LoadedContentPaddingWidget(
            sliver: state.viewMode == FeatureFlagViewMode.list
                ? _ListWidget(flags: state.filteredFlags)
                : _GridWidget(flags: state.filteredFlags),
          ),
        ]),
        FeatureFlagErrorState(:final failure) => ScreenErrorContent(failure),
      },
      onContentVisible: (content) =>
          context.bloc.add(ViewStateVisibleEvent(content.trackingLabel)),
    );
  }
}

/// The page header with the view and reset actions, then the search header
/// pinned below it.
List<Widget> _headerSlivers(
  BuildContext context,
  FeatureFlagLoadedState state,
) {
  return [
    PageAppBarWidget(
      title: context.localizations.developerMenuFeatureFlags,
      actions: [
        _ViewModeButtonWidget(viewMode: state.viewMode),
        const DSHorizontalSpacerWidget(0.5),
        const _ResetButtonWidget(),
        const DSHorizontalSpacerWidget(1),
      ],
    ),
    const PinnedHeaderSliver(child: HeaderWidget()),
  ];
}
