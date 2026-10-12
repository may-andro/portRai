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

/// Shows only [allowedLocations]; any other coordinates render nothing, so the
/// model cannot invent places.
CatalogItem createDsMap(
  List<AssistantLocation> allowedLocations,
) => CatalogItem(
  name: 'DSMap',
  dataSchema: S.object(
    description:
        'An interactive map. Coordinates must be copied exactly from the '
        'portfolio information (the location latitude and longitude); never '
        'invent them.',
    properties: {
      'latitude': S.number(description: 'Exact latitude from the portfolio.'),
      'longitude': S.number(description: 'Exact longitude from the portfolio.'),
      'label': S.string(description: 'Name of the marked place.'),
      'zoom': S.number(
        description: 'Zoom level from 3 (country) to 15 (street).',
      ),
    },
    required: ['latitude', 'longitude'],
  ),
  widgetBuilder: (itemContext) {
    final data = itemContext.data as JsonMap;
    final latitude = data['latitude'];
    final longitude = data['longitude'];
    if (latitude is! num || longitude is! num) return const SizedBox.shrink();
    final isAllowed = allowedLocations.any(
      (location) =>
          (location.latitude - latitude).abs() < _tolerance &&
          (location.longitude - longitude).abs() < _tolerance,
    );
    if (!isAllowed || !_isMapSupported) return const SizedBox.shrink();

    final position = LatLng(latitude.toDouble(), longitude.toDouble());
    final zoom = ((data['zoom'] as num?)?.toDouble() ?? 10).clamp(3.0, 15.0);
    final label = data['label'] as String?;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: position, zoom: zoom),
          markers: {
            Marker(
              markerId: const MarkerId('place'),
              position: position,
              infoWindow: InfoWindow(title: label),
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
