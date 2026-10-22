part of 'content_widget.dart';

/// Switches the flags between the list and the grid.
class _ViewModeButtonWidget extends StatelessWidget {
  const _ViewModeButtonWidget({required this.viewMode});

  final FeatureFlagViewMode viewMode;

  @override
  Widget build(BuildContext context) {
    return DSIconButtonWidget(
      viewMode == FeatureFlagViewMode.list ? Icons.grid_view : Icons.view_list,
      iconColor: context.colorPalette.inverseSurface,
      buttonColor: context.colorPalette.background,
      onPressed: () => context.bloc.add(const ToggleViewModeEvent()),
    );
  }
}

/// Resets every flag to its default value.
class _ResetButtonWidget extends StatelessWidget {
  const _ResetButtonWidget();

  @override
  Widget build(BuildContext context) {
    return DSIconButtonWidget(
      Icons.refresh,
      iconColor: context.colorPalette.inverseSurface,
      buttonColor: context.colorPalette.background,
      onPressed: () => context.bloc.add(const ResetAllFeatureFlagsEvent()),
    );
  }
}
