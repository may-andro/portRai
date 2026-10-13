part of 'service_detail_widget.dart';

/// Fades and slides its child in the first time it scrolls into view.
class _RevealWidget extends StatefulWidget {
  const _RevealWidget({required this.child, this.index = 0});

  final Widget child;

  /// Position among siblings, used to stagger the entrance.
  final int index;

  @override
  State<_RevealWidget> createState() => _RevealWidgetState();
}

class _RevealWidgetState extends State<_RevealWidget> {
  final _key = UniqueKey();
  bool _revealed = false;

  void _onVisibilityChanged(double visiblePercentage) {
    if (_revealed || visiblePercentage < 5) return;
    final delay = Duration(milliseconds: min(widget.index, 5) * 70);
    Future<void>.delayed(delay, () {
      if (mounted) setState(() => _revealed = true);
    });
    _revealed = true;
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

/// Lifts its child slightly while a pointer hovers over it.
class _HoverLiftWidget extends StatefulWidget {
  const _HoverLiftWidget({required this.child});

  final Widget child;

  @override
  State<_HoverLiftWidget> createState() => _HoverLiftWidgetState();
}

class _HoverLiftWidgetState extends State<_HoverLiftWidget> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedSlide(
        offset: _hovering ? const Offset(0, -0.012) : Offset.zero,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        child: AnimatedScale(
          scale: _hovering ? 1.008 : 1,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Nudges its child sideways on hover, for list rows.
class _HoverNudgeWidget extends StatefulWidget {
  const _HoverNudgeWidget({required this.child});

  final Widget child;

  @override
  State<_HoverNudgeWidget> createState() => _HoverNudgeWidgetState();
}

class _HoverNudgeWidgetState extends State<_HoverNudgeWidget> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedSlide(
        offset: _hovering ? const Offset(0.02, 0) : Offset.zero,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Pops its child on hover, for tags.
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
      child: AnimatedScale(
        scale: _hovering ? 1.12 : 1,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutBack,
        child: widget.child,
      ),
    );
  }
}
