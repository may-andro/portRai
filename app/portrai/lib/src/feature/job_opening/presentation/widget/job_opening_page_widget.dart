import 'dart:math';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Widest the page content grows, matching the other portfolio pages.
const jobOpeningMaxContentWidth = 1100.0;

extension JobOpeningPageExtension on BuildContext {
  double get jobOpeningHorizontalPadding {
    switch (deviceResolution) {
      case DSDeviceResolution.mobile:
        return space(factor: 3);
      case DSDeviceResolution.tablet:
        return space(factor: 5);
      case DSDeviceResolution.desktop:
        return width * 0.12;
    }
  }
}

/// Centers [child] in the page column with the page's side padding.
class JobOpeningPageColumnWidget extends StatelessWidget {
  const JobOpeningPageColumnWidget({
    super.key,
    required this.child,
    this.verticalPadding = 0,
  });

  final Widget child;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.jobOpeningHorizontalPadding,
        vertical: verticalPadding,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: jobOpeningMaxContentWidth,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// The slowly drifting shapes behind a page hero, fading into the
/// background towards the copy. Nothing reaches past its top edge, so it
/// lines up with the page header.
class JobOpeningHeroBackgroundWidget extends StatefulWidget {
  const JobOpeningHeroBackgroundWidget({super.key});

  @override
  State<JobOpeningHeroBackgroundWidget> createState() =>
      _JobOpeningHeroBackgroundWidgetState();
}

class _JobOpeningHeroBackgroundWidgetState
    extends State<JobOpeningHeroBackgroundWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 10),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final shapeSize = context.isMobile ? 220.0 : 360.0;

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final drift = (_controller.value - 0.5) * 24;
          return Stack(
            fit: StackFit.expand,
            children: [
              DSFloatingShapesBackgroundWidget(
                color: palette.accent.color.withAlpha(60),
              ),
              Positioned(
                right: context.isMobile ? -90 : 40,
                bottom: context.isMobile ? -120 : -170,
                child: Transform.translate(
                  offset: Offset(-drift * 0.5, drift * 0.4),
                  child: Container(
                    width: shapeSize * 1.4,
                    height: shapeSize * 1.4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: palette.accent.color.withAlpha(55),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: context.isMobile ? 20 : shapeSize * 0.9,
                top: context.isMobile ? 40 : 60,
                child: Transform.translate(
                  offset: Offset(0, drift * 0.6),
                  child: Icon(
                    Icons.add_rounded,
                    size: context.isMobile ? 22 : 30,
                    color: palette.accent.color.withAlpha(150),
                  ),
                ),
              ),
              // Fades the shapes out towards the copy, so the hero meets the
              // page header without an edge.
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      palette.background.color,
                      palette.background.color.withAlpha(210),
                      palette.background.color.withAlpha(20),
                    ],
                    stops: const [0, 0.55, 1],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Fades and slides [child] in the first time it scrolls into view.
class JobOpeningRevealWidget extends StatefulWidget {
  const JobOpeningRevealWidget({super.key, required this.child});

  final Widget child;

  @override
  State<JobOpeningRevealWidget> createState() => _JobOpeningRevealWidgetState();
}

class _JobOpeningRevealWidgetState extends State<JobOpeningRevealWidget> {
  final _key = UniqueKey();
  bool _isRevealed = false;

  void _onVisibilityChanged(double visiblePercentage) {
    if (_isRevealed || visiblePercentage < 5) return;
    setState(() => _isRevealed = true);
  }

  @override
  Widget build(BuildContext context) {
    return DSVisibilityDetectorWidget(
      key: _key,
      onVisibilityChanged: _onVisibilityChanged,
      child: AnimatedSlide(
        offset: _isRevealed ? Offset.zero : const Offset(0, 0.06),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: _isRevealed ? 1 : 0,
          duration: const Duration(milliseconds: 500),
          child: widget.child,
        ),
      ),
    );
  }
}

/// A rounded label with an icon, for facts such as a source or a date.
class JobOpeningPillWidget extends StatelessWidget {
  const JobOpeningPillWidget({
    super.key,
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.space(factor: 1.25),
        vertical: context.space(factor: 0.5),
      ),
      decoration: BoxDecoration(
        color: palette.surface.surfaceContainerHigh.color.withAlpha(200),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: palette.outline.outlineVariant.color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: context.space(factor: 0.5),
        children: [
          Icon(icon, size: 16, color: palette.accent.color),
          Flexible(
            child: DSTextWidget(
              label,
              style: context.typography.labelLarge,
              color: palette.neutral.grey9,
              maxLines: 1,
              textOverflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// A full-width page band. Consecutive bands alternate [isAlternate] so each
/// section stands apart, as on the other portfolio pages.
class JobOpeningBandWidget extends StatelessWidget {
  const JobOpeningBandWidget({
    super.key,
    required this.child,
    this.isAlternate = false,
  });

  final Widget child;
  final bool isAlternate;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.jobOpeningBandColor(isAlternate: isAlternate),
      child: JobOpeningPageColumnWidget(
        verticalPadding: context.jobOpeningBandVerticalPadding,
        child: child,
      ),
    );
  }
}

/// [JobOpeningBandWidget] for a [sliver], so a long list in a band is built
/// lazily as it scrolls into view.
class JobOpeningBandSliverWidget extends StatelessWidget {
  const JobOpeningBandSliverWidget({
    super.key,
    required this.sliver,
    this.isAlternate = false,
  });

  final Widget sliver;
  final bool isAlternate;

  @override
  Widget build(BuildContext context) {
    return DecoratedSliver(
      decoration: BoxDecoration(
        color: context.jobOpeningBandColor(isAlternate: isAlternate),
      ),
      sliver: SliverLayoutBuilder(
        builder: (context, constraints) {
          final pagePadding = context.jobOpeningHorizontalPadding;
          final contentWidth = min(
            constraints.crossAxisExtent - pagePadding * 2,
            jobOpeningMaxContentWidth,
          );
          return SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: max(
                pagePadding,
                (constraints.crossAxisExtent - contentWidth) / 2,
              ),
              vertical: context.jobOpeningBandVerticalPadding,
            ),
            sliver: sliver,
          );
        },
      ),
    );
  }
}

extension on BuildContext {
  Color jobOpeningBandColor({required bool isAlternate}) {
    final palette = colorPalette;
    return isAlternate
        ? Color.alphaBlend(
            palette.accent.color.withAlpha(22),
            palette.background.color,
          )
        : palette.background.color;
  }

  double get jobOpeningBandVerticalPadding => space(factor: isMobile ? 4 : 6);
}

/// A section heading with an icon badge, shared by the page bands.
class JobOpeningSectionTitleWidget extends StatelessWidget {
  const JobOpeningSectionTitleWidget({
    super.key,
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final accent = palette.accent.color;
    return Row(
      spacing: context.space(factor: 1.25),
      children: [
        Container(
          padding: EdgeInsets.all(context.space()),
          decoration: BoxDecoration(
            color: accent.withAlpha(36),
            borderRadius: BorderRadius.circular(
              context.dimen.radiusLevel1.value,
            ),
          ),
          child: Icon(icon, size: 24, color: accent),
        ),
        Flexible(
          child: DSTextWidget(
            title,
            style: context.isMobile
                ? context.typography.emphasizedHeadlineSmall
                : context.typography.emphasizedHeadlineMedium,
            color: palette.neutral.grey10,
          ),
        ),
      ],
    );
  }
}
