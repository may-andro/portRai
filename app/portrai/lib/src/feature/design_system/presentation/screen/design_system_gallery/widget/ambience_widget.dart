part of 'content_widget.dart';

/// Fills the screen with the background of [designSystem], a glow of its
/// brand color and a faint run of its festival effect. It reads the tokens
/// from a [DSTheme], so a new preview does not build a Material theme for it.
class _AmbienceWidget extends StatelessWidget {
  const _AmbienceWidget({required this.designSystem, super.key});

  final DesignSystem designSystem;

  @override
  Widget build(BuildContext context) {
    final palette = DSTheme(
      brightness: context.platformBrightness,
      designSystem: designSystem,
    ).colorPalette;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.background.color,
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 1.2,
          colors: [
            palette.brand.primaryContainer.color,
            palette.background.color,
          ],
        ),
      ),
      child: DSFestiveBackdropWidget(
        shape: DSFestiveBackdropShape.rectangle,
        designSystem: designSystem,
        effectOpacity: 0.3,
        particleCount: 20,
      ),
    );
  }
}
