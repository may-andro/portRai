part of 'content_widget.dart';

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

/// Lifts its child on hover, for tags. Lifting instead of scaling keeps the
/// child from being painted under (and clipped by) neighbouring tags.
class _HoverPopWidget extends StatefulWidget {
  const _HoverPopWidget({required this.child});

  final Widget child;

  @override
  State<_HoverPopWidget> createState() => _HoverPopWidgetState();
}

class _HoverPopWidgetState extends State<_HoverPopWidget> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedSlide(
        offset: _hovering ? const Offset(0, -0.08) : Offset.zero,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
