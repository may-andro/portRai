part of 'content_widget.dart';

/// The apply button, and a note that the app restarts and that the choice
/// lasts until the end of the month.
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
        DSTextWidget(
          localizations.themeGalleryApplyNote,
          style: context.typography.bodySmall,
          color: context.colorPalette.neutral.grey7,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
