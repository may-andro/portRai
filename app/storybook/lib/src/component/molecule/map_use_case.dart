import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

const _placeSets = {
  'One city': [DSMapPlace(latitude: 52.52, longitude: 13.40, label: 'Berlin')],
  'Several countries': [
    DSMapPlace(latitude: 52.52, longitude: 13.40, label: 'Germany'),
    DSMapPlace(latitude: 28.61, longitude: 77.21, label: 'India'),
    DSMapPlace(latitude: 51.51, longitude: -0.13, label: 'United Kingdom'),
    DSMapPlace(
      latitude: 25.20,
      longitude: 55.27,
      label: 'United Arab Emirates',
    ),
  ],
};

@UseCase(name: 'Map', type: DSMapWidget)
Widget buildMap(BuildContext context) {
  final placeSetName = context.knobs.object.dropdown(
    label: 'Places',
    options: _placeSets.keys.toList(),
    initialOption: 'Several countries',
  );
  final isInteractive = context.knobs.boolean(
    label: 'Interactive',
    initialValue: false,
  );
  final marker = context.knobs.object.dropdown(
    label: 'Marker',
    options: DSMapMarker.values,
    initialOption: DSMapMarker.brand,
    labelBuilder: (marker) => marker.name,
  );
  final style = context.knobs.object.dropdown(
    label: 'Style',
    options: DSMapStyle.values,
    initialOption: DSMapStyle.minimal,
    labelBuilder: (style) => style.name,
  );
  final maxZoom = context.knobs.double.slider(
    label: 'Max Zoom',
    initialValue: 10,
    min: 2,
    max: 16,
  );

  return Center(
    child: SizedBox(
      width: 480,
      height: 360,
      child: DSMapWidget(
        key: ValueKey('$isInteractive-$marker'),
        places: _placeSets[placeSetName]!,
        isInteractive: isInteractive,
        marker: marker,
        style: style,
        maxZoom: maxZoom,
      ),
    ),
  );
}
