import 'package:design_system/assets/assets.gen.dart';
import 'package:design_system/src/component/atom/container/ds_visibility_detector_widget.dart';
import 'package:design_system/src/foundation/foundation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Recolors every fill matching [keyPath] in a Lottie file, so the animation
/// follows the active theme instead of the colors baked into the file.
class DSLottieColorOverride {
  const DSLottieColorOverride({required this.keyPath, required this.color});

  final List<String> keyPath;
  final DSColor color;
}

enum DSLottiePlayback {
  /// Plays a single time, the first time the animation becomes visible.
  once,

  /// Loops while visible and pauses when scrolled out of view.
  loop,

  /// Stays on the first frame and plays once each time the `trigger` changes.
  trigger,
}

/// Plays a bundled Lottie animation once visible, see [DSLottiePlayback].
class DSLottieWidget extends StatefulWidget {
  const DSLottieWidget({
    super.key,
    required this.asset,
    required this.size,
    this.aspectRatio = 1,
    this.playback = DSLottiePlayback.once,
    this.colorOverrides = const [],
    this.fallback,
    this.visibilityThreshold = 50,
    this.trigger = 0,
  });

  final LottieGenImage asset;

  /// [size] is the width; the height is `size / aspectRatio`.
  final double size;
  final double aspectRatio;
  final DSLottiePlayback playback;
  final List<DSLottieColorOverride> colorOverrides;

  /// Shown when the animation fails to load.
  final Widget? fallback;

  /// Percentage (0-100) of the widget that must be visible to start playing.
  final double visibilityThreshold;

  /// Replays the animation when it changes, see [DSLottiePlayback.trigger].
  final int trigger;

  @override
  State<DSLottieWidget> createState() => _DSLottieWidgetState();
}

class _DSLottieWidgetState extends State<DSLottieWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);
  final _visibilityKey = UniqueKey();
  bool _hasPlayed = false;
  bool _isVisible = false;

  // Lottie resolves the delegates again whenever it receives a new instance,
  // so they are rebuilt only when the color overrides change.
  late LottieDelegates _delegates = _buildDelegates();

  @override
  void didUpdateWidget(DSLottieWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_hasSameColorOverrides(
      oldWidget.colorOverrides,
      widget.colorOverrides,
    )) {
      _delegates = _buildDelegates();
    }
    if (widget.playback == DSLottiePlayback.trigger &&
        widget.trigger != oldWidget.trigger &&
        _controller.duration != null) {
      _controller.forward(from: 0);
    }
  }

  LottieDelegates _buildDelegates() {
    return LottieDelegates(
      values: [
        for (final override in widget.colorOverrides) ...[
          ValueDelegate.color(override.keyPath, value: override.color.color),
          ValueDelegate.strokeColor(
            override.keyPath,
            value: override.color.color,
          ),
        ],
      ],
    );
  }

  bool _hasSameColorOverrides(
    List<DSLottieColorOverride> previousOverrides,
    List<DSLottieColorOverride> currentOverrides,
  ) {
    if (identical(previousOverrides, currentOverrides)) return true;
    if (previousOverrides.length != currentOverrides.length) return false;
    for (final (overrideIndex, previousOverride) in previousOverrides.indexed) {
      final currentOverride = currentOverrides[overrideIndex];
      if (!listEquals(previousOverride.keyPath, currentOverride.keyPath) ||
          previousOverride.color.color != currentOverride.color.color) {
        return false;
      }
    }
    return true;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onVisibilityChanged(double visiblePercentage) {
    _isVisible = visiblePercentage >= widget.visibilityThreshold;
    _updatePlayback();
  }

  // Visibility and composition loading complete in either order.
  void _updatePlayback() {
    if (!mounted || _controller.duration == null) return;
    switch (widget.playback) {
      case DSLottiePlayback.trigger:
        return;
      case DSLottiePlayback.once:
        if (_hasPlayed || !_isVisible) return;
        _hasPlayed = true;
        _controller.forward(from: 0);
      case DSLottiePlayback.loop:
        if (_isVisible && !_controller.isAnimating) {
          _controller.repeat();
        } else if (!_isVisible) {
          _controller.stop();
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DSVisibilityDetectorWidget(
      key: _visibilityKey,
      onVisibilityChanged: _onVisibilityChanged,
      child: SizedBox(
        width: widget.size,
        height: widget.size / widget.aspectRatio,
        child: widget.asset.lottie(
          package: 'design_system',
          controller: _controller,
          fit: BoxFit.contain,
          delegates: _delegates,
          onLoaded: (composition) {
            _controller.duration = composition.duration;
            _updatePlayback();
          },
          errorBuilder: (_, _, _) => widget.fallback ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}
