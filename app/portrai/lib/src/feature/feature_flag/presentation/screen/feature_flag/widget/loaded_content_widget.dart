part of 'content_widget.dart';

class _LoadedContentWidget extends StatelessWidget {
  const _LoadedContentWidget(this.state);

  final FeatureFlagLoadedState state;

  @override
  Widget build(BuildContext context) {
    if (state.filteredFlags.isEmpty) {
      return _EmptySearchResultWidget(searchQuery: state.searchQuery);
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
              ? _ListWidget(flags: state.filteredFlags)
              : _GridWidget(flags: state.filteredFlags),
        ),
      ),
    );
  }
}
