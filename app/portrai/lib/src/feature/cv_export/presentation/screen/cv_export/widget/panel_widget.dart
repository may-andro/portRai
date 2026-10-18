part of 'content_widget.dart';

class _PanelWidget extends StatelessWidget {
  const _PanelWidget({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DSCardWidget(
      backgroundColor: context.colorPalette.surface.surfaceContainerLow,
      radius: context.dimen.radiusLevel3,
      child: child,
    );
  }
}
