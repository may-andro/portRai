part of 'content_widget.dart';

/// The apply button, and a note that the app restarts and that the choice
/// lasts until the end of the month. The note keeps one height for every
/// design system, so the button does not move while browsing.
class _ApplyPanelWidget extends StatelessWidget {
  const _ApplyPanelWidget({required this.state});

  final DesignSystemGalleryLoadedState state;

  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    return Column(
      children: [
        DSButtonWidget(
          label: state.isPreviewApplied
              ? localizations.themeGalleryInUse
              : localizations.themeGalleryApply,
          icon: state.isPreviewApplied
              ? Icons.check_rounded
              : Icons.auto_awesome_rounded,
          isDisabled: state.isPreviewApplied,
          isLoading: state.isApplying,
          onPressed: () =>
              context.bloc.add(const ApplyDesignSystemClickEvent()),
        ),
        const DSVerticalSpacerWidget(1),
        _SteadyTextWidget(
          designSystems: state.designSystems,
          textOf: (_) => localizations.themeGalleryApplyNote,
          styleOf: (typography) => typography.bodySmall,
          color: context.colorPalette.neutral.grey7,
        ),
      ],
    );
  }
}
