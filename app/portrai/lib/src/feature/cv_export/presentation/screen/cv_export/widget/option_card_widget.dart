part of 'content_widget.dart';

/// The card surface shared with the settings screen.
class _OptionCardWidget extends StatelessWidget {
  const _OptionCardWidget({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DSCardWidget(
      backgroundColor: context.colorPalette.inverseSurface,
      radius: context.dimen.radiusLevel2,
      elevation: context.dimen.elevationLevel1,
      margin: EdgeInsets.only(bottom: context.space(factor: 2)),
      child: child,
    );
  }
}
