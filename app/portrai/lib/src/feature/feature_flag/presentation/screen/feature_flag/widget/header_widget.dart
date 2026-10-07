import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/feature_flag/presentation/screen/feature_flag/bloc/_bloc.dart';
import 'package:portrai/src/feature/feature_flag/presentation/screen/feature_flag/widget/restart_app_tile_widget.dart';
import 'package:portrai/src/feature/feature_flag/presentation/screen/feature_flag/widget/search_widget.dart';

class HeaderWidget extends StatefulWidget {
  const HeaderWidget({super.key});

  @override
  State<HeaderWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  late final TextEditingController _searchController;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _updateSearchController(String searchQuery) {
    if (_searchController.text != searchQuery) {
      final cursorPosition = _searchController.selection.baseOffset;
      _searchController.text = searchQuery;
      _searchController.selection = TextSelection.collapsed(
        offset: cursorPosition.clamp(0, searchQuery.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FeatureFlagBloc, FeatureFlagState>(
      listener: (context, state) {
        if (state is FeatureFlagLoadedState) {
          _updateSearchController(state.searchQuery);
        }
      },
      builder: (context, state) {
        if (state is! FeatureFlagLoadedState) {
          return const SizedBox.shrink();
        }

        return _buildContent(context, state);
      },
    );
  }

  Widget _buildContent(BuildContext context, FeatureFlagLoadedState state) {
    final searchQuery = state.searchQuery;
    final resultCount = state.filteredFlags.length;

    _updateSearchController(searchQuery);

    return DSCardWidget(
      backgroundColor: context.colorPalette.surface.surface,
      elevation: const DSElevation(2),
      radius: const DSRadius(0),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(context.space(factor: 2)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SearchWidget(
              searchController: _searchController,
              focusNode: _focusNode,
              searchQuery: searchQuery,
              onSearch: (value) {
                context.bloc.add(SearchFeatureFlagsEvent(value));
              },
              isEnabled: state.allFlags.isNotEmpty || searchQuery.isNotEmpty,
            ),
            const DSVerticalSpacerWidget(1),
            DSTextWidget(
              context.localizations.featureFlagHeaderTitle(resultCount),
              style: context.typography.labelSmall,
              color: context.colorPalette.onBackground,
            ),
            RestartAppTileWidget(
              hasManipulatedFlags: state.hasManipulatedFlags,
            ),
          ],
        ),
      ),
    );
  }
}
