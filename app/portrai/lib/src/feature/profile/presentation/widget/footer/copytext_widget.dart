part of 'footer_widget.dart';

class _CopytextWidget extends StatelessWidget {
  const _CopytextWidget();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: context.space(factor: 0.25),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DSTextWidget(
          context.localizations.copyright('${DateTime.now().year}'),
          style: context.typography.labelSmall,
          color: context.colorPalette.onInverseSurface,
          textAlign: TextAlign.center,
        ),
        const AppVersionWidget(onInverseSurface: true),
      ],
    );
  }
}
