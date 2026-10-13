part of 'content_widget.dart';

extension on ProfileEntity {
  /// Extra photos shown around the main portrait, never the portrait itself.
  List<String> get backdropImages {
    final others = profileImages
        .where((url) => url.isNotEmpty && url != profileImage)
        .toSet()
        .toList();
    if (others.isEmpty && coverImage.isNotEmpty) return [coverImage];
    return others.take(3).toList();
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
    _revealed = true;
    setState(() {});
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

/// Lifts and slightly enlarges its child while hovered.
class _HoverLiftWidget extends StatefulWidget {
  const _HoverLiftWidget({required this.child, this.scale = 1.02});

  final Widget child;
  final double scale;

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
