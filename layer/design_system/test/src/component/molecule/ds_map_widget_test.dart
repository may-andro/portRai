import 'dart:convert';

import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../util/test_wrapper_widget.dart';

void main() {
  const berlin = DSMapPlace(latitude: 52.52, longitude: 13.40, label: 'Berlin');
  const delhi = DSMapPlace(latitude: 28.61, longitude: 77.21, label: 'Delhi');

  Widget buildSubject(
    DSMapWidget map, {
    Brightness brightness = Brightness.light,
    DesignSystem? designSystem,
    Size size = const Size(400, 300),
  }) => TestWidgetWrapper(
    brightness: brightness,
    designSystem: designSystem ?? DesignSystem.values.first,
    child: Center(
      child: SizedBox.fromSize(size: size, child: map),
    ),
  );

  GoogleMap mapOf(WidgetTester tester) =>
      tester.widget<GoogleMap>(find.byType(GoogleMap));

  group('DSMapWidget', () {
    testWidgets('should draw a still map that ignores gestures by default', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSubject(const DSMapWidget(places: [berlin, delhi])),
      );

      final map = mapOf(tester);
      expect(map.liteModeEnabled, isTrue);
      expect(map.scrollGesturesEnabled, isFalse);
      expect(map.zoomGesturesEnabled, isFalse);
      expect(map.rotateGesturesEnabled, isFalse);
      expect(map.tiltGesturesEnabled, isFalse);
      expect(map.gestureRecognizers, isEmpty);
    });

    testWidgets('should let the user move the map when interactive', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSubject(
          const DSMapWidget(places: [berlin, delhi], isInteractive: true),
        ),
      );

      final map = mapOf(tester);
      expect(map.liteModeEnabled, isFalse);
      expect(map.scrollGesturesEnabled, isTrue);
      expect(map.zoomGesturesEnabled, isTrue);
      expect(map.gestureRecognizers, hasLength(1));
    });

    testWidgets('should mark every place with its label', (tester) async {
      await tester.pumpWidget(
        buildSubject(const DSMapWidget(places: [berlin, delhi])),
      );

      final markers = mapOf(tester).markers;
      expect(
        markers.map((marker) => marker.position),
        unorderedEquals(const [LatLng(52.52, 13.40), LatLng(28.61, 77.21)]),
      );
      expect(
        markers.map((marker) => marker.infoWindow.title),
        unorderedEquals(['Berlin', 'Delhi']),
      );
    });

    testWidgets('should center a single place at the max zoom', (tester) async {
      await tester.pumpWidget(
        buildSubject(const DSMapWidget(places: [berlin], maxZoom: 11)),
      );

      final camera = mapOf(tester).initialCameraPosition;
      expect(camera.target, const LatLng(52.52, 13.40));
      expect(camera.zoom, 11);
    });

    List<Map<String, dynamic>> styleRulesOf(WidgetTester tester) =>
        (jsonDecode(mapOf(tester).style!) as List).cast<Map<String, dynamic>>();

    String? colorOf(
      List<Map<String, dynamic>> rules, {
      String? feature,
      required String element,
    }) {
      final rule = rules.lastWhere(
        (rule) =>
            rule['featureType'] == feature && rule['elementType'] == element,
      );
      final stylers = (rule['stylers'] as List).cast<Map<String, dynamic>>();
      return stylers.first['color'] as String?;
    }

    String hexOf(DSColor color) =>
        '#${(color.color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

    for (final designSystem in DesignSystem.values) {
      for (final brightness in Brightness.values) {
        testWidgets('should color the map from the ${designSystem.name} '
            '${brightness.name} palette', (tester) async {
          final palette = DSTheme(
            brightness: brightness,
            designSystem: designSystem,
          ).colorPalette;
          await tester.pumpWidget(
            buildSubject(
              const DSMapWidget(places: [berlin]),
              brightness: brightness,
              designSystem: designSystem,
            ),
          );

          final rules = styleRulesOf(tester);
          expect(
            colorOf(rules, element: 'geometry'),
            hexOf(palette.surface.surfaceContainerLow),
          );
          expect(
            colorOf(rules, feature: 'water', element: 'geometry'),
            hexOf(palette.brand.primaryContainer),
          );
          expect(
            colorOf(
              rules,
              feature: 'administrative.country',
              element: 'geometry.stroke',
            ),
            hexOf(palette.outline.outline),
          );
        });
      }
    }

    testWidgets('should hide roads and points of interest when minimal', (
      tester,
    ) async {
      bool hidesFeature(List<Map<String, dynamic>> rules, String feature) =>
          rules.any(
            (rule) =>
                rule['featureType'] == feature &&
                (rule['stylers'] as List).any(
                  (styler) => (styler as Map)['visibility'] == 'off',
                ),
          );

      await tester.pumpWidget(
        buildSubject(const DSMapWidget(places: [berlin])),
      );
      final standardRules = styleRulesOf(tester);

      await tester.pumpWidget(
        buildSubject(
          const DSMapWidget(places: [berlin], style: DSMapStyle.minimal),
        ),
      );
      final minimalRules = styleRulesOf(tester);

      for (final feature in ['road', 'poi', 'transit']) {
        expect(hidesFeature(standardRules, feature), isFalse);
        expect(hidesFeature(minimalRules, feature), isTrue);
      }
    });

    testWidgets('should replace the default pin once the brand pin is drawn', (
      tester,
    ) async {
      // Drawing the pin needs real async; at zero size the map never creates
      // its platform view, which has no implementation in tests.
      await tester.runAsync(() async {
        await tester.pumpWidget(
          buildSubject(
            const DSMapWidget(places: [berlin], marker: DSMapMarker.brand),
            size: Size.zero,
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pump();

      expect(
        mapOf(tester).markers.single.icon,
        isNot(BitmapDescriptor.defaultMarker),
      );
    });

    testWidgets('should render nothing when there are no places', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject(const DSMapWidget(places: [])));

      expect(find.byType(GoogleMap), findsNothing);
    });

    testWidgets('should render nothing when the platform has no maps', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);

      await tester.pumpWidget(
        buildSubject(const DSMapWidget(places: [berlin])),
      );

      expect(DSMapWidget.isSupported, isFalse);
      expect(find.byType(GoogleMap), findsNothing);
      debugDefaultTargetPlatformOverride = null;
    });
  });
}
