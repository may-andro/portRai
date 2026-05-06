import 'package:flutter/material.dart';

class DSHoverableContainerWidget extends StatefulWidget {
  const DSHoverableContainerWidget({
    required this.builder,
    this.onHoverChange,
    super.key,
  });

  final Widget Function(BuildContext context, bool isHovering) builder;
  final ValueChanged<bool>? onHoverChange;

  @override
  State<DSHoverableContainerWidget> createState() =>
      _DSHoverableContainerWidgetState();
}

class _DSHoverableContainerWidgetState
    extends State<DSHoverableContainerWidget> {
  bool _isHovering = false;

  void _onMouseEnter(bool hovering) {
    setState(() {
      _isHovering = hovering;
    });
    widget.onHoverChange?.call(hovering);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onMouseEnter(true),
      onExit: (_) => _onMouseEnter(false),
      child: widget.builder(context, _isHovering),
    );
  }
}
