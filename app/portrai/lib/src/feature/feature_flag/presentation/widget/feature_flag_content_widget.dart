import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/feature_flag/presentation/bloc/_bloc.dart';
import 'package:portrai/src/feature/feature_flag/presentation/widget/empty_search_result_widget.dart';
import 'package:portrai/src/feature/feature_flag/presentation/widget/feature_flag_grid_widget.dart';
import 'package:portrai/src/feature/feature_flag/presentation/widget/feature_flag_list_widget.dart';

class FeatureFlagContentWidget extends StatelessWidget {
  const FeatureFlagContentWidget(this.state, {super.key});

  final FeatureFlagLoadedState state;

  @override
  Widget build(BuildContext context) {
    if (state.filteredFlags.isEmpty) {
      return EmptySearchResultWidget(searchQuery: state.searchQuery);
    }

    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.space(factor: 2),
            vertical: context.space(factor: context.isDesktop ? 2 : 1),
          ),
          child: state.viewMode == FeatureFlagViewMode.list
              ? FeatureFlagListWidget(flags: state.filteredFlags)
              : FeatureFlagGridWidget(flags: state.filteredFlags),
        ),
      ),
    );
  }
}
