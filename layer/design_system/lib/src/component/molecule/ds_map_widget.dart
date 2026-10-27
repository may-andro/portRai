import 'dart:math';
import 'dart:ui';

import 'package:design_system/src/component/atom/lottie/lottie.dart';
import 'package:design_system/src/extension/build_context_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// A place marked on a [DSMapWidget].
class DSMapPlace extends Equatable {
  const DSMapPlace({
    required this.latitude,
    required this.longitude,
    this.label,
  });

  final double latitude;
  final double longitude;

  /// Shown in the info window when the marker is tapped.
  final String? label;

  @override
  List<Object?> get props => [latitude, longitude, label];
}

enum DSMapMarker {
  /// The platform's default pin.
  standard,

  /// A gradient pin in the brand colors. On a map that is not interactive it
  /// also pulses.
  brand,
}

enum DSMapStyle {
  /// The platform's default map.
  standard,

  /// Hides roads and points of interest and follows the theme brightness.
  minimal,
}

/// Google Map with one marker per place, framed so every place is in view.
///
/// Unless [isInteractive], the map cannot be moved: the page keeps scrolling
/// over it, markers stay tappable, and Android draws it as a still image
/// (lite mode), which is far cheaper to create and to scroll past.
///
/// Renders nothing when [places] is empty or the platform has no Google Maps
/// support, see [isSupported].
class DSMapWidget extends StatefulWidget {
  const DSMapWidget({
    super.key,
    required this.places,
    this.isInteractive = false,
    this.marker = DSMapMarker.standard,
    this.style = DSMapStyle.standard,
    this.maxZoom = 10,
    this.borderRadius,
  });

  /// Whether Google Maps can be shown on the current platform.
  static bool get isSupported =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  final List<DSMapPlace> places;

  /// Lets the user pan, zoom, rotate and tilt the map.
  final bool isInteractive;

  final DSMapMarker marker;
  final DSMapStyle style;

  /// Zoom used when the places are too close together to frame, such as a
  /// single place.
  final double maxZoom;

  /// Defaults to the theme's `radiusLevel3`.
  final BorderRadius? borderRadius;

  @override
  State<DSMapWidget> createState() => _DSMapWidgetState();
}

class _DSMapWidgetState extends State<DSMapWidget> {
  static const _framePadding = 64.0;
  static const _pulseSize = 72.0;

  GoogleMapController? _controller;
  BitmapDescriptor? _brandMarker;
  (Color, Color)? _brandMarkerColors;
  List<Offset> _pulseOffsets = const [];

  bool get _showsPulse =>
      widget.marker == DSMapMarker.brand && !widget.isInteractive;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateBrandMarker();
  }

  @override
  void didUpdateWidget(DSMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateBrandMarker();
    final controller = _controller;
    if (controller != null && !listEquals(oldWidget.places, widget.places)) {
      _frame(controller);
    }
  }

  void _updateBrandMarker() {
    if (widget.marker != DSMapMarker.brand) return;
    final palette = context.colorPalette;
    final colors = (palette.brand.primary.color, palette.brand.secondary.color);
    if (colors == _brandMarkerColors) return;
    _brandMarkerColors = colors;
    _buildBrandMarker(colors.$1, colors.$2).then((marker) {
      if (mounted && colors == _brandMarkerColors) {
        setState(() => _brandMarker = marker);
      }
    });
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    _controller = controller;
    await _frame(controller);
  }

  /// Fits every place in view, then measures where the pulses go. The camera
  /// of a map that is not interactive never moves, so measuring once is enough.
  Future<void> _frame(GoogleMapController controller) async {
    final places = widget.places;
    if (places.length > 1) {
      await controller.moveCamera(
        CameraUpdate.newLatLngBounds(_boundsOf(places), _framePadding),
      );
    }
    if (!_showsPulse || !mounted) return;
    // Android reports physical pixels, the other platforms logical ones.
    final pixelRatio = defaultTargetPlatform == TargetPlatform.android
        ? MediaQuery.devicePixelRatioOf(context)
        : 1.0;
    final pulseOffsets = <Offset>[];
    for (final place in places) {
      final point = await controller.getScreenCoordinate(
        LatLng(place.latitude, place.longitude),
      );
      pulseOffsets.add(Offset(point.x / pixelRatio, point.y / pixelRatio));
    }
    if (mounted) setState(() => _pulseOffsets = pulseOffsets);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.places.isEmpty || !DSMapWidget.isSupported) {
      return const SizedBox.shrink();
    }
    final isInteractive = widget.isInteractive;
    final map = GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: _cameraFor(widget.places, widget.maxZoom),
      style: _mapStyle(context),
      markers: {
        for (final (placeIndex, place) in widget.places.indexed)
          Marker(
            markerId: MarkerId('place_$placeIndex'),
            position: LatLng(place.latitude, place.longitude),
            icon: widget.marker == DSMapMarker.brand
                ? _brandMarker ?? BitmapDescriptor.defaultMarker
                : BitmapDescriptor.defaultMarker,
            anchor: widget.marker == DSMapMarker.brand
                ? const Offset(0.5, 0.92)
                : const Offset(0.5, 1),
            infoWindow: InfoWindow(title: place.label),
          ),
      },
      liteModeEnabled: !isInteractive,
      scrollGesturesEnabled: isInteractive,
      zoomGesturesEnabled: isInteractive,
      rotateGesturesEnabled: isInteractive,
      tiltGesturesEnabled: isInteractive,
      gestureRecognizers: isInteractive
          ? const {
              Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new),
            }
          : const {},
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      myLocationButtonEnabled: false,
    );

    return ClipRRect(
      borderRadius:
          widget.borderRadius ??
          BorderRadius.circular(context.dimen.radiusLevel3.value),
      child: !_showsPulse
          ? map
          : Stack(
              fit: StackFit.expand,
              children: [
                map,
                for (final offset in _pulseOffsets)
                  Positioned(
                    left: offset.dx - _pulseSize / 2,
                    top: offset.dy - _pulseSize / 2,
                    width: _pulseSize,
                    height: _pulseSize,
                    child: IgnorePointer(
                      child: DSLottieIllustrationWidget(
                        illustration: DSLottieIllustration.pinPulse,
                        width: _pulseSize,
                        colorOverrides: [
                          DSLottieColorOverride(
                            keyPath: const ['Pulse', '**'],
                            color: context.colorPalette.brand.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  String? _mapStyle(BuildContext context) {
    switch (widget.style) {
      case DSMapStyle.standard:
        return null;
      case DSMapStyle.minimal:
        return context.theme.brightness == Brightness.dark
            ? _minimalDarkStyle
            : _minimalLightStyle;
    }
  }
}

LatLngBounds _boundsOf(List<DSMapPlace> places) {
  final latitudes = places.map((place) => place.latitude);
  final longitudes = places.map((place) => place.longitude);
  return LatLngBounds(
    southwest: LatLng(latitudes.reduce(min), longitudes.reduce(min)),
    northeast: LatLng(latitudes.reduce(max), longitudes.reduce(max)),
  );
}

/// Centers on the places with a zoom that roughly fits their span, so the
/// first frame is close to the framed view.
CameraPosition _cameraFor(List<DSMapPlace> places, double maxZoom) {
  final bounds = _boundsOf(places);
  final southwest = bounds.southwest;
  final northeast = bounds.northeast;
  final span = max(
    northeast.longitude - southwest.longitude,
    (northeast.latitude - southwest.latitude) * 4 / 3,
  );
  final minZoom = min(1.5, maxZoom);
  final zoom = span < 0.01
      ? maxZoom
      : (log(420 / span) / ln2 - 0.2).clamp(minZoom, maxZoom);
  return CameraPosition(
    target: LatLng(
      (southwest.latitude + northeast.latitude) / 2,
      (southwest.longitude + northeast.longitude) / 2,
    ),
    zoom: zoom,
  );
}

/// Draws a glowing gradient pin with a white core.
Future<BitmapDescriptor> _buildBrandMarker(
  Color primary,
  Color secondary,
) async {
  const width = 96.0;
  const height = 128.0;
  const radius = 34.0;
  const center = Offset(width / 2, 44);
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder);

  canvas.drawOval(
    Rect.fromCenter(
      center: const Offset(width / 2, height - 10),
      width: 44,
      height: 12,
    ),
    Paint()
      ..color = Colors.black.withAlpha(90)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
  );

  final pin = Path()
    ..moveTo(width / 2, height - 14)
    ..cubicTo(
      width / 2 - 8,
      height - 38,
      center.dx - radius,
      center.dy + 24,
      center.dx - radius,
      center.dy,
    )
    ..arcTo(Rect.fromCircle(center: center, radius: radius), pi, pi, false)
    ..cubicTo(
      center.dx + radius,
      center.dy + 24,
      width / 2 + 8,
      height - 38,
      width / 2,
      height - 14,
    )
    ..close();

  canvas
    ..drawPath(
      pin,
      Paint()
        ..color = primary.withAlpha(150)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
    )
    ..drawPath(
      pin,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary, secondary],
        ).createShader(const Rect.fromLTWH(0, 0, width, height)),
    )
    ..drawPath(
      pin,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = Colors.white,
    )
    ..drawCircle(center, 15, Paint()..color = Colors.white)
    ..drawCircle(center, 7, Paint()..color = primary);

  final image = await recorder.endRecording().toImage(
    width.toInt(),
    height.toInt(),
  );
  final bytes = await image.toByteData(format: ImageByteFormat.png);
  return BitmapDescriptor.bytes(
    bytes!.buffer.asUint8List(),
    width: 34,
    height: 45,
  );
}

const _minimalLightStyle =
    '[{"featureType":"road","stylers":[{"visibility":"off"}]},'
    '{"featureType":"poi","stylers":[{"visibility":"off"}]},'
    '{"featureType":"water","elementType":"geometry",'
    '"stylers":[{"color":"#cfe3f5"}]}]';

const _minimalDarkStyle =
    '[{"elementType":"geometry","stylers":[{"color":"#1d2c4d"}]},'
    '{"elementType":"labels.text.fill","stylers":[{"color":"#8ec3b9"}]},'
    '{"elementType":"labels.text.stroke","stylers":[{"color":"#1a3646"}]},'
    '{"featureType":"water","elementType":"geometry",'
    '"stylers":[{"color":"#0e1626"}]},'
    '{"featureType":"road","stylers":[{"visibility":"off"}]},'
    '{"featureType":"poi","stylers":[{"visibility":"off"}]},'
    '{"featureType":"administrative.country","elementType":"geometry.stroke",'
    '"stylers":[{"color":"#4b6878"}]}]';
