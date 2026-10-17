import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/expertise/domain/entity/expertise_entity.dart';
import 'package:portrai/src/feature/expertise/domain/entity/skill_entity.dart';
import 'package:portrai/src/feature/expertise/presentation/widget/expertise_orbit/expertise_orbit_widget.dart';

import 'package:visibility_detector/visibility_detector.dart';

import '../../../../../../util/test_wrapper_widget.dart';

void main() {
  final expertises = [
    for (final title in ['Flutter Development', 'Native Android', 'Testing'])
      ExpertiseEntity(
        image: 'https://example.com/$title.png',
        title: title,
        skills: [SkillEntity(name: '$title skill')],
      ),
  ];

  setUp(() {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  });

  Future<Size> pumpOrbit(WidgetTester tester, Size size) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 3));
    });

    await tester.pumpWidget(
      TestWidgetWrapper(
        child: SingleChildScrollView(
          child: ExpertiseOrbitWidget(expertises: expertises, isVisible: true),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    return tester.getSize(find.byType(ExpertiseOrbitWidget));
  }

  for (final size in {
    'mobile': const Size(390, 844),
    'desktop': const Size(1440, 900),
  }.entries) {
    testWidgets('should show the first expertise when on ${size.key}', (
      tester,
    ) async {
      await pumpOrbit(tester, size.value);

      expect(find.text('Flutter Development'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('should not use the bird icon when an expertise is Flutter', (
    tester,
  ) async {
    await pumpOrbit(tester, const Size(1440, 900));

    expect(find.byIcon(Icons.flutter_dash), findsNothing);
  });
}
