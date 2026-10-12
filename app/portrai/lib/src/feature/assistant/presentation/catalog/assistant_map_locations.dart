import 'dart:convert';

typedef AssistantLocation = ({double latitude, double longitude});

/// Coordinates present in the portfolio context, the only places the model may map.
List<AssistantLocation> assistantLocationsFrom(String portfolioContext) {
  final locations = <AssistantLocation>[];
  void visit(Object? node) {
    if (node is Map) {
      final latitude = node['latitude'];
      final longitude = node['longitude'];
      if (latitude is num && longitude is num) {
        locations.add((
          latitude: latitude.toDouble(),
          longitude: longitude.toDouble(),
        ));
      }
      node.values.forEach(visit);
    } else if (node is List) {
      node.forEach(visit);
    }
  }

  try {
    visit(jsonDecode(portfolioContext));
  } on FormatException {
    return const [];
  }
  return locations;
}
