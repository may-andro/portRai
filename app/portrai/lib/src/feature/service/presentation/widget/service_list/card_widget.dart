part of 'service_list_widget.dart';

class _CardWidget extends StatelessWidget {
  const _CardWidget({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DSCardWidget(
      elevation: context.dimen.elevationLevel1,
      backgroundColor: context.colorPalette.containerHigh,
      radius: context.dimen.radiusLevel2,
      onTap: () {},
      child: Padding(
        padding: EdgeInsets.all(context.space(factor: 2)),
        child: child,
      ),
    );
  }
}
