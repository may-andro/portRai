part of 'content_widget.dart';

bool get _isMapSupported =>
    kIsWeb ||
    defaultTargetPlatform == TargetPlatform.android ||
    defaultTargetPlatform == TargetPlatform.iOS;

/// Brand band with the "worked across the globe" story, the key numbers and a
/// map marking every country the projects were shipped to.
class _GlobalBandWidget extends StatelessWidget {
  const _GlobalBandWidget({
    required this.profile,
    required this.workPlaces,
    required this.isDesktop,
  });

  final ProfileEntity profile;
  final List<WorkPlaceEntity> workPlaces;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final showMap = workPlaces.isNotEmpty && _isMapSupported;
    final text = _GlobalTextWidget(
      profile: profile,
      workPlaces: workPlaces,
      isDesktop: isDesktop,
    );

    final chips = Wrap(
      spacing: context.space(),
      runSpacing: context.space(),
      children: [
        for (final place in workPlaces) _CountryChipWidget(place.country),
      ],
    );

    return PageBandWidget(
      verticalFactor: isDesktop ? 5 : 3,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [palette.brand.primary.color, palette.brand.secondary.color],
      ),
      background: const _BandDecorationWidget(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: context.space(factor: 4),
        children: [
          if (showMap && isDesktop)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: context.space(factor: 6),
                children: [
                  Expanded(flex: 5, child: text),
                  Expanded(
                    flex: 6,
                    child: _WorkMapWidget(places: workPlaces, fill: true),
                  ),
                ],
              ),
            )
          else ...[
            text,
            if (showMap) _WorkMapWidget(places: workPlaces),
          ],
          if (workPlaces.isNotEmpty) chips,
        ],
      ),
    );
  }
}

class _GlobalTextWidget extends StatelessWidget {
  const _GlobalTextWidget({
    required this.profile,
    required this.workPlaces,
    required this.isDesktop,
  });

  final ProfileEntity profile;
  final List<WorkPlaceEntity> workPlaces;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: context.space(factor: 2),
      children: [
        PageEyebrowWidget(localizations.profileGlobalEyebrow, onDark: true),
        DSTextWidget(
          localizations.profileGlobalTitle,
          style: isDesktop
              ? context.typography.emphasizedDisplaySmall
              : context.typography.emphasizedHeadlineMedium,
          color: pageOnDarkColor,
        ),
        DSTextWidget(
          localizations.profileGlobalDescription,
          style: context.typography.bodyLarge,
          color: pageOnDarkColor,
        ),
        SizedBox(height: context.space(factor: 0.5)),
        Wrap(
          spacing: context.space(factor: 4),
          runSpacing: context.space(factor: 2),
          children: [
            _GlobalStatWidget(
              icon: const DSLottieIconWidget(
                icon: DSLottieIcon.folder,
                size: 48,
                color: Colors.white,
                playback: DSLottiePlayback.loop,
              ),
              value: '${profile.projectsDelivered}+',
              label: localizations.profileProjects,
            ),
            if (workPlaces.isNotEmpty)
              _GlobalStatWidget(
                // The globe artwork fills only part of its canvas, so it is
                // scaled up to match the other stat icons.
                icon: SizedBox.square(
                  dimension: 48,
                  child: Transform.scale(
                    scale: 1.6,
                    child: const DSLottieIllustrationWidget(
                      illustration: DSLottieIllustration.globe,
                      width: 48,
                    ),
                  ),
                ),
                value: '${workPlaces.length}',
                label: localizations.profileCountries,
              )
            else
              _GlobalStatWidget(
                icon: const DSLottieIconWidget(
                  icon: DSLottieIcon.language,
                  size: 48,
                  color: Colors.white,
                  playback: DSLottiePlayback.loop,
                ),
                value: '${profile.languages.length}',
                label: localizations.profileLanguages,
              ),
          ],
        ),
      ],
    );
  }
}

class _GlobalStatWidget extends StatelessWidget {
  const _GlobalStatWidget({
    required this.icon,
    required this.value,
    required this.label,
  });

  final Widget icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return HoverLiftWidget(
      scale: 1.05,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: context.space(factor: 1.5),
        children: [
          icon,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CountUpWidget(
                value: value,
                style: context.typography.emphasizedHeadlineMedium,
                color: pageOnDarkColor,
              ),
              DSTextWidget(
                label.toUpperCase(),
                style: context.typography.emphasizedLabelMedium,
                color: pageOnDarkColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CountryChipWidget extends StatelessWidget {
  const _CountryChipWidget(this.country);

  final String country;

  @override
  Widget build(BuildContext context) {
    return HoverLiftWidget(
      scale: 1.06,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.space(factor: 1.5),
          vertical: context.space(factor: 0.5),
        ),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(28),
          borderRadius: BorderRadius.circular(
            context.dimen.radiusCircular.value,
          ),
          border: Border.all(color: Colors.white.withAlpha(120)),
        ),
        child: DSTextWidget(
          country,
          style: context.typography.emphasizedLabelLarge,
          color: pageOnDarkColor,
        ),
      ),
    );
  }
}

/// Non-scrolling map so the page keeps scrolling; markers stay tappable.
class _WorkMapWidget extends StatefulWidget {
  const _WorkMapWidget({required this.places, this.fill = false});

  final List<WorkPlaceEntity> places;

  /// Stretches to the parent's height instead of using a fixed aspect ratio.
  final bool fill;

  @override
  State<_WorkMapWidget> createState() => _WorkMapWidgetState();
}

class _WorkMapWidgetState extends State<_WorkMapWidget> {
  static const _aspectRatio = 4 / 3;
  static const _pulseSize = 72.0;

  BitmapDescriptor? _marker;
  bool _markerRequested = false;
  List<Offset> _pinOffsets = const [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_markerRequested) return;
    _markerRequested = true;
    final palette = context.colorPalette;
    _buildMarker(
      palette.brand.primary.color,
      palette.brand.secondary.color,
    ).then((marker) {
      if (mounted) setState(() => _marker = marker);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return HoverLiftWidget(
      scale: 1.01,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withAlpha(150), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(70),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: _sized(
            Stack(
              fit: StackFit.expand,
              children: [
                _buildMap(isDark),
                for (final offset in _pinOffsets)
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
          ),
        ),
      ),
    );
  }

  Widget _buildMap(bool isDark) {
    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: _cameraFor(widget.places),
      style: isDark ? _darkMapStyle : _lightMapStyle,
      markers: {
        for (final (index, place) in widget.places.indexed)
          Marker(
            markerId: MarkerId('place_$index'),
            position: LatLng(place.latitude, place.longitude),
            icon: _marker ?? BitmapDescriptor.defaultMarker,
            anchor: const Offset(0.5, 0.92),
            infoWindow: InfoWindow(title: place.country),
          ),
      },
      // The map never moves, so Android draws it as a still image instead of
      // a live view, which is far cheaper to create and to scroll past.
      liteModeEnabled: true,
      scrollGesturesEnabled: false,
      zoomGesturesEnabled: false,
      rotateGesturesEnabled: false,
      tiltGesturesEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      myLocationButtonEnabled: false,
    );
  }

  /// The camera is static, so pin positions are measured once after fitting.
  Future<void> _onMapCreated(GoogleMapController controller) async {
    final pixelRatio = defaultTargetPlatform == TargetPlatform.android
        ? MediaQuery.devicePixelRatioOf(context)
        : 1.0;
    await _fitPlaces(controller);
    final offsets = <Offset>[];
    for (final place in widget.places) {
      final point = await controller.getScreenCoordinate(
        LatLng(place.latitude, place.longitude),
      );
      offsets.add(Offset(point.x / pixelRatio, point.y / pixelRatio));
    }
    if (mounted) setState(() => _pinOffsets = offsets);
  }

  Widget _sized(Widget map) {
    if (!widget.fill) return AspectRatio(aspectRatio: _aspectRatio, child: map);
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 340),
      child: map,
    );
  }

  /// Zooms so every marker, including the pin heads, is inside the view.
  Future<void> _fitPlaces(GoogleMapController controller) async {
    final places = widget.places;
    if (places.length < 2) return;
    final latitudes = places.map((place) => place.latitude);
    final longitudes = places.map((place) => place.longitude);
    final bounds = LatLngBounds(
      southwest: LatLng(latitudes.reduce(min), longitudes.reduce(min)),
      northeast: LatLng(latitudes.reduce(max), longitudes.reduce(max)),
    );
    await controller.moveCamera(CameraUpdate.newLatLngBounds(bounds, 64));
  }

  /// Centres on the places and picks the zoom that fits their span.
  CameraPosition _cameraFor(List<WorkPlaceEntity> places) {
    final latitudes = places.map((place) => place.latitude);
    final longitudes = places.map((place) => place.longitude);
    final minLat = latitudes.reduce(min);
    final maxLat = latitudes.reduce(max);
    final minLng = longitudes.reduce(min);
    final maxLng = longitudes.reduce(max);
    final span = max(maxLng - minLng, (maxLat - minLat) * _aspectRatio);
    final zoom = span < 0.01
        ? 6.0
        : (log(420 / span) / ln2 - 0.2).clamp(1.5, 6.0);
    return CameraPosition(
      target: LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2),
      zoom: zoom,
    );
  }
}

/// Draws a glowing gradient pin with a white core.
Future<BitmapDescriptor> _buildMarker(Color primary, Color secondary) async {
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

const _lightMapStyle =
    '[{"featureType":"road","stylers":[{"visibility":"off"}]},'
    '{"featureType":"poi","stylers":[{"visibility":"off"}]},'
    '{"featureType":"water","elementType":"geometry",'
    '"stylers":[{"color":"#cfe3f5"}]}]';

const _darkMapStyle =
    '[{"elementType":"geometry","stylers":[{"color":"#1d2c4d"}]},'
    '{"elementType":"labels.text.fill","stylers":[{"color":"#8ec3b9"}]},'
    '{"elementType":"labels.text.stroke","stylers":[{"color":"#1a3646"}]},'
    '{"featureType":"water","elementType":"geometry",'
    '"stylers":[{"color":"#0e1626"}]},'
    '{"featureType":"road","stylers":[{"visibility":"off"}]},'
    '{"featureType":"poi","stylers":[{"visibility":"off"}]},'
    '{"featureType":"administrative.country","elementType":"geometry.stroke",'
    '"stylers":[{"color":"#4b6878"}]}]';
