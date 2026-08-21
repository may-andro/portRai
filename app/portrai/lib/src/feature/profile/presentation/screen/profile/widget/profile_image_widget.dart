part of 'content_widget.dart';

class _ProfileImageWidget extends StatelessWidget {
  const _ProfileImageWidget({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return DSCardWidget(
      backgroundColor: context.colorPalette.surface.surface,
      shadowColor: context.colorPalette.surface.inverseSurface,
      elevation: context.dimen.elevationLevel3,
      radius: context.dimen.radiusCircular,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Padding(
        padding: EdgeInsets.all(context.space(factor: 0.2)),
        child: DSNetworkImageWidget(
          url: url,
          fit: BoxFit.contain,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
