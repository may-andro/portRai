import 'package:design_system/src/component/atom/atom.dart';
import 'package:design_system/src/extension/build_context_extension.dart';
import 'package:design_system/src/extension/ds_color_roles_extension.dart';
import 'package:design_system/src/foundation/color/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// A single animated tab item used inside a [TabBar].
///
/// Shows [title] text with an optional animated underline indicator:
/// - **selected** → a short solid underline at 80 % of text width
/// - **hovered** → an animated expanding underline at 90 % of text width
/// - **default** → no indicator
class DSTabItemWidget extends StatefulWidget {
  const DSTabItemWidget({
    super.key,
    required this.title,
    required this.onTap,
    this.isSelected = false,
    this.isIndicatorEnabled = false,
  });

  final String title;
  final GestureTapCallback onTap;
  final bool isSelected;
  final bool isIndicatorEnabled;

  static double getHeight(BuildContext context) {
    return context.getTextHeight(context.typography.bodyLarge, 1) +
        context.space() * 2 +
        context.space(factor: 0.2);
  }

  @override
  State<DSTabItemWidget> createState() => _DSTabItemWidgetState();
}

class _DSTabItemWidgetState extends State<DSTabItemWidget>
    with SingleTickerProviderStateMixin {
  bool _isHovering = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: 450.ms);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textWidth = context.getTextWidth(
      widget.title,
      context.typography.bodyLarge,
    );

    return MouseRegion(
      onEnter: (_) => _setHover(true),
      onExit: (_) => _setHover(false),
      child: InkWell(
        onTap: widget.onTap,
        child: Padding(
          padding: EdgeInsets.all(context.space()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DSTextWidget(
                widget.title,
                color: _textColor,
                style: context.typography.bodyLarge,
              ),
              if (widget.isIndicatorEnabled) ...[
                if (widget.isSelected)
                  _DSTabSelectedIndicatorWidget(width: textWidth * 0.8)
                else
                  _DSTabHoverIndicatorWidget(
                    isHover: _isHovering,
                    width: textWidth * 0.9,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _setHover(bool hovering) {
    setState(() => _isHovering = hovering);
    if (hovering) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  DSColor get _textColor {
    if (_isHovering || widget.isSelected) {
      return context.colorPalette.onBackground;
    }
    return context.colorPalette.neutral.grey6;
  }
}

class _DSTabSelectedIndicatorWidget extends StatelessWidget {
  const _DSTabSelectedIndicatorWidget({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.85,
      child: Container(
        width: width,
        height: context.space(factor: 0.2),
        color: context.colorPalette.onBackground.color,
      ),
    );
  }
}

class _DSTabHoverIndicatorWidget extends StatelessWidget {
  const _DSTabHoverIndicatorWidget({
    required this.width,
    required this.isHover,
  });

  final double width;
  final bool isHover;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      width: isHover ? width : 0,
      height: context.space(factor: 0.2),
      color: context.colorPalette.onBackground.color,
      duration: 300.ms,
      curve: Curves.linearToEaseOut,
    );
  }
}
