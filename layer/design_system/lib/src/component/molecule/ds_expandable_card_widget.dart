import 'package:design_system/src/component/atom/atom.dart';
import 'package:design_system/src/extension/build_context_extension.dart';
import 'package:design_system/src/extension/ds_color_roles_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// A generic animated expandable card.
///
/// Shows [headerContent] at all times inside a padded row alongside a rotating
/// chevron. Tapping the card toggles an animated [SizeTransition] that reveals
/// or hides [expandedContent].
class DSExpandableCardWidget extends StatefulWidget {
  const DSExpandableCardWidget({
    super.key,
    required this.headerContent,
    required this.expandedContent,
  });

  final Widget headerContent;
  final Widget expandedContent;

  @override
  State<DSExpandableCardWidget> createState() => _DSExpandableCardWidgetState();
}

class _DSExpandableCardWidgetState extends State<DSExpandableCardWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: 400.ms, vsync: this);
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
  }

  void _toggleExpand() {
    if (_expanded) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() => _expanded = !_expanded);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = context.colorPalette.containerHighest;
    final borderRadius = BorderRadius.circular(
      context.dimen.radiusLevel2.value,
    );
    final elevation = _expanded
        ? context.dimen.elevationLevel3
        : context.dimen.elevationLevel1;

    return GestureDetector(
      onTap: _toggleExpand,
      child: Material(
        elevation: elevation.value,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(color: backgroundColor.color),
        ),
        color: backgroundColor.color,
        child: ClipRRect(
          borderRadius: borderRadius,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DSExpandableHeaderWidget(
                expanded: _expanded,
                child: widget.headerContent,
              ),
              _DSExpandableBodyWidget(
                expandAnimation: _expandAnimation,
                child: widget.expandedContent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DSExpandableHeaderWidget extends StatelessWidget {
  const _DSExpandableHeaderWidget({
    required this.child,
    required this.expanded,
  });

  final Widget child;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.space(factor: 2)),
      child: Row(
        children: [
          Expanded(child: child),
          AnimatedRotation(
            turns: expanded ? 0.5 : 0,
            duration: 300.ms,
            curve: Curves.easeOut,
            child: DSIconWidget(
              Icons.arrow_drop_down,
              color: context.colorPalette.surface.onSurface,
              size: DSIconSize.large,
            ),
          ),
        ],
      ),
    );
  }
}

class _DSExpandableBodyWidget extends StatelessWidget {
  const _DSExpandableBodyWidget({
    required this.child,
    required this.expandAnimation,
  });

  final Widget child;
  final Animation<double> expandAnimation;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: SizeTransition(
        sizeFactor: expandAnimation,
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            context.space(factor: 2),
            0,
            context.space(factor: 2),
            context.space(factor: 2),
          ),
          child: child,
        ),
      ),
    );
  }
}
