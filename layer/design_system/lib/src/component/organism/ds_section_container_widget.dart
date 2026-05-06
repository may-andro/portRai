import 'package:design_system/src/component/atom/atom.dart';
import 'package:design_system/src/extension/build_context_extension.dart';
import 'package:design_system/src/extension/ds_color_roles_extension.dart';
import 'package:design_system/src/foundation/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

// ---------------------------------------------------------------------------
// Section Background
// ---------------------------------------------------------------------------

/// Defines the colour strategy for a [DSSectionContainerWidget] pane.
sealed class DSSectionBackground {
  const DSSectionBackground();

  DSColor getBgColor(BuildContext context);

  DSColor getTextColor(BuildContext context);
}

/// Dark/inverse background – uses [DSColorPalette.inverseSurface].
final class DSInverseSectionBackground extends DSSectionBackground {
  const DSInverseSectionBackground();

  @override
  DSColor getBgColor(BuildContext context) =>
      context.colorPalette.inverseSurface;

  @override
  DSColor getTextColor(BuildContext context) =>
      context.colorPalette.onInverseSurface;
}

/// Standard surface background – uses [DSColorPalette.background].
final class DSSurfaceSectionBackground extends DSSectionBackground {
  const DSSurfaceSectionBackground();

  @override
  DSColor getBgColor(BuildContext context) => context.colorPalette.background;

  @override
  DSColor getTextColor(BuildContext context) =>
      context.colorPalette.onBackground;
}

// ---------------------------------------------------------------------------
// Section Action
// ---------------------------------------------------------------------------

/// An optional CTA button rendered in the section header.
class DSSectionAction {
  const DSSectionAction({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  Widget build(BuildContext context) {
    return DSButtonWidget(
      label: label,
      onPressed: onPressed,
      size: DSButtonSize.extraSmall,
    );
  }
}

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

const double _kVisibilityThreshold = 5.0;

/// A generic section container used to compose portfolio page sections.
///
/// Features:
/// - Themed background via [DSSectionBackground]
/// - Optional animated title + action row
/// - Visibility-triggered entry animations
/// - Responsive horizontal padding
class DSSectionContainerWidget extends StatefulWidget {
  const DSSectionContainerWidget({
    super.key,
    required this.builder,
    required this.visibilityKey,
    this.background = const DSSurfaceSectionBackground(),
    this.hasBottomPadding = true,
    this.horizontalPadding,
    this.title,
    this.action,
  });

  /// Content builder – receives the [BuildContext] and whether the section is
  /// currently visible on screen.
  final Widget Function(BuildContext context, bool isVisible) builder;

  /// Unique key used by the underlying [DSVisibilityDetectorWidget].
  final String visibilityKey;

  /// Background colour strategy. Defaults to [DSSurfaceSectionBackground].
  final DSSectionBackground background;

  /// Whether to add bottom spacing after the content. Defaults to `true`.
  final bool hasBottomPadding;

  /// Override the default responsive horizontal padding (in logical pixels).
  final double? horizontalPadding;

  /// Optional section title displayed in the header row.
  final String? title;

  /// Optional action button shown next to the title.
  final DSSectionAction? action;

  @override
  State<DSSectionContainerWidget> createState() =>
      _DSSectionContainerWidgetState();
}

class _DSSectionContainerWidgetState extends State<DSSectionContainerWidget> {
  bool _isVisible = false;

  double _horizontalPadding(BuildContext context) {
    if (widget.horizontalPadding != null) return widget.horizontalPadding!;
    switch (context.deviceResolution) {
      case DSDeviceResolution.mobile:
        return context.space(factor: 3);
      case DSDeviceResolution.tablet:
        return context.space(factor: 5);
      case DSDeviceResolution.desktop:
        return context.width * 0.15;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DSVisibilityDetectorWidget(
      key: Key('${widget.visibilityKey}_section_visibility_detector'),
      onVisibilityChanged: _onVisibilityChanged,
      child: ColoredBox(
        color: widget.background.getBgColor(context).color,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.title case final String title) ...[
              _HeaderWidget(
                title: title,
                background: widget.background,
                isVisible: _isVisible,
                action: widget.action,
                horizontalPadding: _horizontalPadding(context),
              ),
            ],
            ClipRect(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: _horizontalPadding(context),
                ),
                child: widget.builder(context, _isVisible),
              ),
            ),
            if (widget.hasBottomPadding) const DSVerticalSpacerWidget(3),
          ],
        ),
      ),
    );
  }

  void _onVisibilityChanged(double visiblePercentage) {
    if (_isVisible) return;
    if (visiblePercentage < _kVisibilityThreshold) return;
    setState(() => _isVisible = true);
  }
}

// ---------------------------------------------------------------------------
// Header Widget (private)
// ---------------------------------------------------------------------------

class _HeaderWidget extends StatelessWidget {
  const _HeaderWidget({
    required this.title,
    required this.background,
    required this.isVisible,
    required this.horizontalPadding,
    this.action,
  });

  final String title;
  final DSSectionBackground background;
  final bool isVisible;
  final DSSectionAction? action;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: context.space(factor: 3),
        horizontal: horizontalPadding,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DSTextWidget(
                title,
                style: context.typography.emphasizedTitleLarge,
                color: background.getTextColor(context),
              )
              .animate(target: isVisible ? 1 : 0)
              .slideX(
                begin: -0.5,
                duration: 300.ms,
                delay: Duration.zero,
                curve: Curves.easeOut,
              )
              .fadeIn(delay: 100.ms, duration: 300.ms),
          if (action case final DSSectionAction action) ...[
            action
                .build(context)
                .animate(target: isVisible ? 1 : 0)
                .slideX(
                  begin: 0.5,
                  duration: 300.ms,
                  delay: Duration.zero,
                  curve: Curves.easeOut,
                )
                .fadeIn(delay: 100.ms, duration: 300.ms),
          ],
        ],
      ),
    );
  }
}
