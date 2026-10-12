import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:portrai/src/feature/assistant/presentation/catalog/assistant_map_locations.dart';

const _tolerance = 0.001;

bool get _isMapSupported =>
    kIsWeb ||
    defaultTargetPlatform == TargetPlatform.android ||
    defaultTargetPlatform == TargetPlatform.iOS;

const _maxPlaces = 12;

/// Shows only [allowedLocations]; places outside them are dropped, so the
/// model cannot invent places.
CatalogItem createDsMap(
  List<AssistantLocation> allowedLocations,
) => CatalogItem(
  name: 'DSMap',
  dataSchema: S.object(
    description:
        'An interactive map with one marker per place. Coordinates must be '
        'copied exactly from the portfolio information (profile location or '
        'experience latitude and longitude); never invent them.',
    properties: {
      'places': S.list(
        description: 'Places to mark, at most $_maxPlaces.',
        items: S.object(
          properties: {
            'latitude': S.number(description: 'Exact latitude.'),
            'longitude': S.number(description: 'Exact longitude.'),
            'label': S.string(description: 'Name of the place.'),
          },
          required: ['latitude', 'longitude'],
        ),
      ),
    },
    required: ['places'],
  ),
  widgetBuilder: (itemContext) {
    final data = itemContext.data as JsonMap;
    final places = <({LatLng position, String? label})>[];
    for (final place in (data['places'] as List?) ?? const []) {
      if (place is! Map) continue;
      final latitude = place['latitude'];
      final longitude = place['longitude'];
      if (latitude is! num || longitude is! num) continue;
      final isAllowed = allowedLocations.any(
        (location) =>
            (location.latitude - latitude).abs() < _tolerance &&
            (location.longitude - longitude).abs() < _tolerance,
      );
      if (!isAllowed) continue;
      places.add((
        position: LatLng(latitude.toDouble(), longitude.toDouble()),
        label: place['label'] as String?,
      ));
      if (places.length == _maxPlaces) break;
    }
    if (places.isEmpty || !_isMapSupported) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: GoogleMap(
          initialCameraPosition: _cameraFor([
            for (final place in places) place.position,
          ]),
          markers: {
            for (final (index, place) in places.indexed)
              Marker(
                markerId: MarkerId('place_$index'),
                position: place.position,
                infoWindow: InfoWindow(title: place.label),
              ),
          },
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          myLocationButtonEnabled: false,
          gestureRecognizers: const {
            Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new),
          },
        ),
      ),
    );
  },
);

/// Centers on the markers and picks the zoom that fits their span in 16:9.
CameraPosition _cameraFor(List<LatLng> positions) {
  final latitudes = positions.map((position) => position.latitude);
  final longitudes = positions.map((position) => position.longitude);
  final minLat = latitudes.reduce(math.min);
  final maxLat = latitudes.reduce(math.max);
  final minLng = longitudes.reduce(math.min);
  final maxLng = longitudes.reduce(math.max);
  final span = math.max(maxLng - minLng, (maxLat - minLat) * 16 / 9);
  final zoom = span < 0.01
      ? 10.0
      : (math.log(506 / span) / math.ln2 - 0.4).clamp(2.0, 10.0);
  return CameraPosition(
    target: LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2),
    zoom: zoom,
  );
}
