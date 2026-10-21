part of 'content_widget.dart';

class _JobSearchCardWidget extends StatelessWidget {
  const _JobSearchCardWidget({
    required this.isEnabled,
    required this.isUpdating,
  });

  final bool isEnabled;
  final bool isUpdating;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    return DSCardWidget(
      backgroundColor: palette.inverseSurface,
      radius: context.dimen.radiusLevel2,
      elevation: context.dimen.elevationLevel1,
      child: SwitchListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: context.space(factor: 2),
        ),
        value: isEnabled,
        onChanged: isUpdating
            ? null
            : (isEnabled) => context.bloc.add(
                JobSearchToggleClickEvent(isEnabled: isEnabled),
              ),
        title: DSTextWidget(
          context.localizations.jobSearchToggleTitle,
          color: palette.neutral.grey1,
          style: context.typography.titleMedium,
        ),
        subtitle: DSTextWidget(
          context.localizations.jobSearchToggleDescription,
          color: palette.neutral.grey3,
          style: context.typography.bodyMedium,
        ),
      ),
    );
  }
}
