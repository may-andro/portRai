part of 'content_widget.dart';

/// Fills the screen with the background of the ambient design system, a glow
/// of its brand color and a faint run of its festival effect.
class _AmbienceWidget extends StatelessWidget {
  const _AmbienceWidget();

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
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
      child: const DSFestiveBackdropWidget(
        shape: DSFestiveBackdropShape.rectangle,
        effectOpacity: 0.3,
        particleCount: 20,
      ),
    );
  }
}
