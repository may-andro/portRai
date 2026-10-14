part of 'content_widget.dart';

/// Full-width page section with its own background, like the profile bands.
class _BandWidget extends StatelessWidget {
  const _BandWidget({
    required this.child,
    this.color,
    this.background,
    this.verticalFactor = 8,
  });

  final Widget child;
  final Color? color;
  final Widget? background;
  final double verticalFactor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: color,
      child: Stack(
        children: [
          if (background != null) Positioned.fill(child: background!),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.horizontalPadding,
              vertical: context.space(factor: verticalFactor),
            ),
            child: _RevealWidget(child: child),
          ),
        ],
      ),
    );
  }
}

/// Small spaced-out label with a gradient dash, e.g. "SKILLS ——".
class _EyebrowWidget extends StatelessWidget {
  const _EyebrowWidget(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: context.space(),
      children: [
        Flexible(
          child: DSTextWidget(
            label.toUpperCase(),
            style: context.typography.emphasizedLabelLarge,
            color: palette.neutral.grey7,
          ),
        ),
        Container(
          width: 48,
          height: 4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: LinearGradient(
              colors: [
                palette.brand.primary.color,
                palette.brand.secondary.color,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Fades and slides its child in the first time it scrolls into view.
class _RevealWidget extends StatefulWidget {
  const _RevealWidget({required this.child});

  final Widget child;

  @override
  State<_RevealWidget> createState() => _RevealWidgetState();
}

class _RevealWidgetState extends State<_RevealWidget> {
  final _key = UniqueKey();
  bool _revealed = false;

  void _onVisibilityChanged(double visiblePercentage) {
    if (_revealed || visiblePercentage < 5) return;
    setState(() => _revealed = true);
  }

  @override
  Widget build(BuildContext context) {
    return DSVisibilityDetectorWidget(
      key: _key,
      onVisibilityChanged: _onVisibilityChanged,
      child: AnimatedSlide(
        offset: _revealed ? Offset.zero : const Offset(0, 0.06),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: _revealed ? 1 : 0,
          duration: const Duration(milliseconds: 500),
          child: widget.child,
        ),
      ),
    );
  }
}

/// A few large crisp copies of the expertise image, half cropped by the edges
/// of the section. Static and isolated in its own layer, so it costs nothing
/// while scrolling. [tint] turns them into flat silhouettes.
class _ImageAccentsWidget extends StatelessWidget {
  const _ImageAccentsWidget({
    required this.imageUrl,
    this.opacity = 0.07,
    this.tint,
  });

  final String imageUrl;
  final double opacity;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final size = context.isMobile ? 220.0 : 380.0;

    Widget accent(Alignment alignment, Offset shift, double angle) {
      Widget image = DSNetworkImageWidget(url: imageUrl, fit: BoxFit.contain);
      if (tint != null) {
        image = ColorFiltered(
          colorFilter: ColorFilter.mode(tint!, BlendMode.srcIn),
          child: image,
        );
      }
      return Align(
        alignment: alignment,
        child: FractionalTranslation(
          translation: shift,
          child: Transform.rotate(
            angle: angle,
            child: SizedBox.square(dimension: size, child: image),
          ),
        ),
      );
    }

    return IgnorePointer(
      child: RepaintBoundary(
        child: ClipRect(
          child: Opacity(
            opacity: opacity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                accent(Alignment.topRight, const Offset(0.3, -0.1), 0.25),
                accent(Alignment.centerLeft, const Offset(-0.4, 0), -0.2),
                accent(Alignment.bottomRight, const Offset(0.25, 0.2), -0.12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
