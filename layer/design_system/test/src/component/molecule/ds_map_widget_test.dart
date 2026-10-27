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
    Size size = const Size(400, 300),
  }) => TestWidgetWrapper(
    brightness: brightness,
    designSystem: DesignSystem.values.first,
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

    testWidgets('should keep the platform map style when standard', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSubject(const DSMapWidget(places: [berlin])),
      );

      expect(mapOf(tester).style, isNull);
    });

    testWidgets('should use a different minimal style in light and dark', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSubject(
          const DSMapWidget(places: [berlin], style: DSMapStyle.minimal),
        ),
      );
      final lightStyle = mapOf(tester).style;

      await tester.pumpWidget(
        buildSubject(
          const DSMapWidget(places: [berlin], style: DSMapStyle.minimal),
          brightness: Brightness.dark,
        ),
      );
      final darkStyle = mapOf(tester).style;

      expect(lightStyle, isNotNull);
      expect(darkStyle, isNotNull);
      expect(darkStyle, isNot(lightStyle));
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
