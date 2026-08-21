import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

const double _visibilityThreshold = 5.0;

sealed class SectionBackground {
  const SectionBackground();

  DSColor getBgColor(BuildContext context);

  DSColor getTextColor(BuildContext context);
}

final class InverseSectionBackground extends SectionBackground {
  const InverseSectionBackground();

  @override
  DSColor getBgColor(BuildContext context) {
    return context.colorPalette.surface.inverseSurface;
  }

  @override
  DSColor getTextColor(BuildContext context) {
    return context.colorPalette.surface.onInverseSurface;
  }
}

final class SurfaceSectionBackground extends SectionBackground {
  const SurfaceSectionBackground();

  @override
  DSColor getBgColor(BuildContext context) {
    return context.colorPalette.surface.surface;
  }

  @override
  DSColor getTextColor(BuildContext context) {
    return context.colorPalette.surface.onSurface;
  }
}

class SectionAction {
  const SectionAction({required this.label, required this.onPressed});

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

class SectionContainerWidget extends StatefulWidget {
  const SectionContainerWidget({
    super.key,
    required this.builder,
    required this.visibilityKey,
    this.background = const SurfaceSectionBackground(),
    this.hasBottomPadding = true,
    this.horizontalPadding,
    this.title,
    this.action,
  });

  final Widget Function(BuildContext context, bool isVisible) builder;
  final String visibilityKey;
  final SectionBackground background;
  final bool hasBottomPadding;
  final double? horizontalPadding;
  final String? title;
  final SectionAction? action;

  @override
  State<SectionContainerWidget> createState() => _SectionContainerWidgetState();
}

class _SectionContainerWidgetState extends State<SectionContainerWidget> {
  bool _isVisible = false;

  Widget get verticalSpacerWidget => const DSVerticalSpacerWidget(3);

  double get horizontalPadding {
    return widget.horizontalPadding ?? context.horizontalScreenPaddingDimen;
  }

  @override
  Widget build(BuildContext context) {
    return DSVisibilityDetectorWidget(
      key: Key('${widget.visibilityKey}_content_visibility_detector'),
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
              ),
            ],
            ClipRect(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: widget.builder(context, _isVisible),
              ),
            ),
            if (widget.hasBottomPadding) ...[const DSVerticalSpacerWidget(3)],
          ],
        ),
      ),
    );
  }

  void _onVisibilityChanged(double visiblePercentage) {
    if (_isVisible) return;

    if (visiblePercentage < _visibilityThreshold) return;

    setState(() => _isVisible = true);
  }
}

class _HeaderWidget extends StatelessWidget {
  const _HeaderWidget({
    required this.title,
    required this.background,
    required this.isVisible,
    this.action,
  });

  final String title;
  final SectionBackground background;
  final bool isVisible;
  final SectionAction? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(
        vertical: context.space(factor: 3),
        horizontal: context.horizontalScreenPaddingDimen,
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
                delay: 0.ms,
                curve: Curves.easeOut,
              )
              .fadeIn(delay: 100.ms, duration: 300.ms),
          if (action case final SectionAction action) ...[
            action
                .build(context)
                .animate(target: isVisible ? 1 : 0)
                .slideX(
                  begin: 0.5,
                  duration: 300.ms,
                  delay: 0.ms,
                  curve: Curves.easeOut,
                )
                .fadeIn(delay: 100.ms, duration: 300.ms),
          ],
        ],
      ),
    );
  }
}

extension on BuildContext {
  double get horizontalScreenPaddingDimen {
    switch (deviceResolution) {
      case DSDeviceResolution.mobile:
        return space(factor: 3);
      case DSDeviceResolution.tablet:
        return space(factor: 5);
      case DSDeviceResolution.desktop:
        return width * 0.15;
    }
  }
}
