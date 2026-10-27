import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:portrai/src/feature/assistant/presentation/catalog/assistant_map_locations.dart';

const _tolerance = 0.001;

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
    final places = <DSMapPlace>[];
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
      places.add(
        DSMapPlace(
          latitude: latitude.toDouble(),
          longitude: longitude.toDouble(),
          label: place['label'] as String?,
        ),
      );
      if (places.length == _maxPlaces) break;
    }
    if (places.isEmpty || !DSMapWidget.isSupported) {
      return const SizedBox.shrink();
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: DSMapWidget(
        places: places,
        isInteractive: true,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  },
);
