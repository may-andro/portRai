import 'package:design_system/src/component/atom/container/ds_visibility_detector_widget.dart';
import 'package:flutter/material.dart';

/// Pauses the animations of [child] while none of it is on screen, so a
/// looping animation stops requesting frames once it is scrolled away.
///
/// [child] also gets its own repaint boundary, so its animation frames do not
/// repaint the rest of the screen.
class DSOffscreenPauseWidget extends StatefulWidget {
  const DSOffscreenPauseWidget({super.key, required this.child});

  final Widget child;

  @override
  State<DSOffscreenPauseWidget> createState() => _DSOffscreenPauseWidgetState();
}

class _DSOffscreenPauseWidgetState extends State<DSOffscreenPauseWidget> {
  final _visibilityKey = UniqueKey();

  // Animations run until the first visibility report says otherwise.
  bool _isOnScreen = true;

  void _onVisibilityChanged(double visiblePercentage) {
    final isOnScreen = visiblePercentage > 0;
    if (!mounted || isOnScreen == _isOnScreen) return;
    setState(() => _isOnScreen = isOnScreen);
  }

  @override
  Widget build(BuildContext context) {
    return DSVisibilityDetectorWidget(
      key: _visibilityKey,
      onVisibilityChanged: _onVisibilityChanged,
      child: TickerMode(
        enabled: _isOnScreen,
        child: RepaintBoundary(child: widget.child),
      ),
    );
  }
}
