part of 'content_widget.dart';

/// Centered text in the ambient design system that takes the height of its
/// tallest look across [designSystems], so moving between design systems does
/// not shift what is around it.
class _SteadyTextWidget extends StatelessWidget {
  const _SteadyTextWidget(
    this.text, {
    required this.designSystems,
    required this.styleOf,
    required this.color,
  });

  final String text;
  final List<DesignSystem> designSystems;
  final DSTextStyle Function(DSTypography typography) styleOf;
  final DSColor color;

  @override
  Widget build(BuildContext context) {
    final brightness = context.platformBrightness;
    return SizedBox(
      width: double.infinity,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          for (final designSystem in designSystems)
            Visibility(
              visible: false,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: DSTextWidget(
                text,
                style: styleOf(
                  DSTheme(
                    brightness: brightness,
                    designSystem: designSystem,
                  ).typography,
                ),
                color: color,
                textAlign: TextAlign.center,
              ),
            ),
          DSTextWidget(
            text,
            style: styleOf(context.typography),
            color: color,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
