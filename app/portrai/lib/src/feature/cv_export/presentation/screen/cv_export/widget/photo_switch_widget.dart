part of 'content_widget.dart';

class _PhotoSwitchWidget extends StatelessWidget {
  const _PhotoSwitchWidget({required this.isIncluded});

  final bool isIncluded;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;

    return Material(
      color: palette.surface.surface.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.dimen.radiusLevel2.value),
        side: BorderSide(color: palette.outline.outlineVariant.color),
      ),
      clipBehavior: Clip.antiAlias,
      child: SwitchListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: context.space(factor: 2),
        ),
        secondary: Icon(
          Icons.account_circle_outlined,
          color: palette.surface.onSurfaceVariant.color,
        ),
        value: isIncluded,
        onChanged: (isIncluded) {
          context.bloc.add(ToggleCvPhotoClickEvent(isIncluded: isIncluded));
        },
        title: DSTextWidget(
          context.localizations.cvExportIncludePhoto,
          style: context.typography.bodyMedium,
          color: palette.surface.onSurface,
        ),
      ),
    );
  }
}
