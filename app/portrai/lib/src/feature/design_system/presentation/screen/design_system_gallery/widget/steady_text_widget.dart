part of 'content_widget.dart';

/// Text in the ambient design system that takes the height of the tallest
/// text [textOf] gives across [designSystems], each in its own style, so
/// moving between design systems does not shift what is around it.
class _SteadyTextWidget extends StatelessWidget {
  const _SteadyTextWidget({
    required this.designSystems,
    required this.textOf,
    required this.styleOf,
    required this.color,
    this.textAlign = TextAlign.center,
    this.maxLines,
  });

  final List<DesignSystem> designSystems;
  final String Function(DesignSystem designSystem) textOf;
  final DSTextStyle Function(DSTypography typography) styleOf;
  final DSColor color;
  final TextAlign textAlign;
  final int? maxLines;

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
              child: _buildText(
                textOf(designSystem),
                DSTheme(
                  brightness: brightness,
                  designSystem: designSystem,
                ).typography,
              ),
            ),
          _buildText(textOf(context.theme.designSystem), context.typography),
        ],
      ),
    );
  }

  Widget _buildText(String text, DSTypography typography) => DSTextWidget(
    text,
    style: styleOf(typography),
    color: color,
    textAlign: textAlign,
    maxLines: maxLines,
    textOverflow: maxLines == null ? null : TextOverflow.ellipsis,
  );
}
