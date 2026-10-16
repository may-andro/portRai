import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

const pageOnDarkColor = DSColor(0xFFFFFFFF);

/// Horizontal inset shared by every band so content lines up down the page.
double pageHorizontalInset(BuildContext context) {
  return switch (context.deviceResolution) {
    DSDeviceResolution.mobile => context.space(factor: 3),
    DSDeviceResolution.tablet => context.space(factor: 5),
    DSDeviceResolution.desktop => context.width * 0.15,
  };
}

/// Full-width page section with its own background.
class PageBandWidget extends StatelessWidget {
  const PageBandWidget({
    super.key,
    required this.child,
    this.color,
    this.gradient,
    this.background,
    this.verticalFactor = 8,
  });

  final Widget child;
  final Color? color;
  final Gradient? gradient;
  final Widget? background;
  final double verticalFactor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: color, gradient: gradient),
      child: Stack(
        children: [
          if (background != null) Positioned.fill(child: background!),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: pageHorizontalInset(context),
              vertical: context.space(factor: verticalFactor),
            ),
            child: RevealWidget(child: child),
          ),
        ],
      ),
    );
  }
}

/// Small spaced-out label with a gradient dash, e.g. "ABOUT ME ——".
class PageEyebrowWidget extends StatelessWidget {
  const PageEyebrowWidget(this.label, {super.key, this.onDark = false});

  final String label;
  final bool onDark;

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
            color: onDark ? pageOnDarkColor : palette.neutral.grey7,
          ),
        ),
        Container(
          width: 48,
          height: 4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: LinearGradient(
              colors: onDark
                  ? [Colors.white54, Colors.white10]
                  : [
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

/// A [PageBandWidget] with an eyebrow title above its content.
class PageSectionBandWidget extends StatelessWidget {
  const PageSectionBandWidget({
    super.key,
    required this.title,
    required this.child,
    this.color,
    this.gradient,
    this.background,
    this.onDark = false,
  });

  final String title;
  final Widget child;
  final Color? color;
  final Gradient? gradient;
  final Widget? background;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return PageBandWidget(
      color: color,
      gradient: gradient,
      background: background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: context.space(factor: 2.5),
        children: [
          PageEyebrowWidget(title, onDark: onDark),
          child,
        ],
      ),
    );
  }
}

/// Counts a value like "10+" up from zero the first time it appears.
class CountUpWidget extends StatelessWidget {
  const CountUpWidget({
    super.key,
    required this.value,
    required this.style,
    required this.color,
  });

  final String value;
  final DSTextStyle style;
  final DSColor color;

  @override
  Widget build(BuildContext context) {
    final match = RegExp(r'^(\D*?)(\d+(?:\.\d+)?)(.*)$').firstMatch(value);
    if (match == null) {
      return DSTextWidget(value, style: style, color: color);
    }
    final prefix = match.group(1)!;
    final number = match.group(2)!;
    final suffix = match.group(3)!;
    final decimalPlaces = number.contains('.')
        ? number.length - number.indexOf('.') - 1
        : 0;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: double.parse(number)),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, count, _) {
        return DSTextWidget(
          '$prefix${count.toStringAsFixed(decimalPlaces)}$suffix',
          style: style,
          color: color,
        );
      },
    );
  }
}

/// Fades and slides its child in the first time it scrolls into view.
class RevealWidget extends StatefulWidget {
  const RevealWidget({super.key, required this.child});

  final Widget child;

  @override
  State<RevealWidget> createState() => _RevealWidgetState();
}

class _RevealWidgetState extends State<RevealWidget> {
  final _visibilityKey = UniqueKey();
  bool _revealed = false;

  void _onVisibilityChanged(double visiblePercentage) {
    if (_revealed || visiblePercentage < 5) return;
    _revealed = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DSVisibilityDetectorWidget(
      key: _visibilityKey,
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

/// Lifts and slightly enlarges its child while hovered.
class HoverLiftWidget extends StatefulWidget {
  const HoverLiftWidget({super.key, required this.child, this.scale = 1.02});

  final Widget child;
  final double scale;

  @override
  State<HoverLiftWidget> createState() => _HoverLiftWidgetState();
}

class _HoverLiftWidgetState extends State<HoverLiftWidget> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedSlide(
        offset: _hovering ? const Offset(0, -0.02) : Offset.zero,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: AnimatedScale(
          scale: _hovering ? widget.scale : 1,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}
