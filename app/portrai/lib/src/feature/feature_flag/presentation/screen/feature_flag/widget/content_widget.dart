import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/feature_flag/domain/_domain.dart';
import 'package:portrai/src/feature/feature_flag/presentation/screen/feature_flag/bloc/_bloc.dart';
import 'package:portrai/src/widget/screen_content_widget.dart';

part 'loaded_content_widget.dart';

part 'grid_widget.dart';

part 'grid_item_widget.dart';

part 'list_widget.dart';

part 'list_item_widget.dart';

part 'empty_search_result_widget.dart';

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
        FeatureFlagLoadedState(:final filteredFlags, :final searchQuery)
            when filteredFlags.isEmpty =>
          ScreenLoadedContent.slivers([
            SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptySearchResultWidget(searchQuery: searchQuery),
            ),
          ]),
        FeatureFlagLoadedState(:final filteredFlags, :final viewMode) =>
          ScreenLoadedContent.slivers([
            _LoadedContentPaddingWidget(
              sliver: viewMode == FeatureFlagViewMode.list
                  ? _ListWidget(flags: filteredFlags)
                  : _GridWidget(flags: filteredFlags),
            ),
          ]),
        FeatureFlagErrorState(:final failure) => ScreenErrorContent(failure),
      },
      onContentVisible: (content) =>
          context.bloc.add(ViewStateVisibleEvent(content.trackingLabel)),
    );
  }
}
