import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:portrai/src/feature/expertise/domain/entity/expertise_entity.dart';
import 'package:portrai/src/feature/expertise/domain/entity/skill_entity.dart';
import 'package:portrai/src/feature/expertise/presentation/screen/expertise/expertise_screen.dart';
import 'package:portrai/src/feature/expertise/presentation/widget/expertise_orbit/expertise_orbit_widget.dart';

import 'package:visibility_detector/visibility_detector.dart';

import '../../../../../../util/test_wrapper_widget.dart';

void main() {
  const mobileSize = Size(390, 844);
  const desktopSize = Size(1440, 900);

  final expertises = [
    for (final title in [
      'Flutter Development',
      'Native Android',
      'Testing',
      'Mobile Architecture and Clean Code Practices',
      'Accessibility',
      'Design Systems',
    ])
      ExpertiseEntity(
        image: 'https://example.com/$title.png',
        title: title,
        skills: [SkillEntity(name: '$title skill')],
      ),
  ];

  Finder dialNode(String title) => find.byWidgetPredicate(
    (widget) => widget is Semantics && widget.properties.label == title,
  );

  setUp(() {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  });

  // Animations start counting on their first frame, so pump frame by frame.
  Future<void> settle(WidgetTester tester) async {
    for (var frame = 0; frame < 25; frame++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<Size> pumpOrbit(
    WidgetTester tester,
    Size size, {
    ValueChanged<ExpertiseEntity>? onOpen,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 3));
    });

    final orbit = SingleChildScrollView(
      child: ExpertiseOrbitWidget(
        expertises: expertises,
        isVisible: true,
        onOpen: onOpen,
      ),
    );
    await tester.pumpWidget(
      TestWidgetWrapper(
        routerConfig: GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => Scaffold(body: orbit),
            ),
            GoRoute(
              name: 'expertise',
              path: '/expertise/:${ExpertiseScreen.routePathParameter}',
              builder: (context, state) => Scaffold(
                body: Text('Opened ${(state.extra! as ExpertiseEntity).title}'),
              ),
            ),
          ],
        ),
        child: const SizedBox(),
      ),
    );
    await settle(tester);
    tester.takeException();
    return tester.getSize(find.byType(ExpertiseOrbitWidget));
  }

  for (final size in {'mobile': mobileSize, 'desktop': desktopSize}.entries) {
    testWidgets('should show the first expertise when on ${size.key}', (
      tester,
    ) async {
      await pumpOrbit(tester, size.value);

      expect(find.text('Flutter Development'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'should open the selected expertise when view details is tapped on '
      '${size.key}',
      (tester) async {
        await pumpOrbit(tester, size.value);

        // Mobile has an arrow button, desktop a labelled one.
        await tester.tap(
          size.value == mobileSize
              ? find.byTooltip('View details')
              : find.text('View details'),
        );
        await settle(tester);

        expect(find.text('Opened Flutter Development'), findsOneWidget);
      },
    );
  }

  testWidgets('should not use the bird icon when an expertise is Flutter', (
    tester,
  ) async {
    await pumpOrbit(tester, desktopSize);

    expect(find.byIcon(Icons.flutter_dash), findsNothing);
  });

  testWidgets('should show the next expertise when the dial is swiped left', (
    tester,
  ) async {
    await pumpOrbit(tester, mobileSize);

    await tester.drag(dialNode('Flutter Development'), const Offset(-120, 0));
    await settle(tester);

    expect(find.text('Native Android'), findsOneWidget);
    expect(find.text('Flutter Development'), findsNothing);
  });

  testWidgets('should show the expertise when its node on the dial is tapped', (
    tester,
  ) async {
    await pumpOrbit(tester, mobileSize);

    await tester.tap(dialNode('Native Android'));
    await settle(tester);

    expect(find.text('Native Android'), findsOneWidget);
    expect(find.text('Opened Native Android'), findsNothing);
  });

  testWidgets(
    'should open and report the expertise when its selected node on the dial '
    'is tapped',
    (tester) async {
      final openedTitles = <String>[];
      await pumpOrbit(
        tester,
        mobileSize,
        onOpen: (expertise) => openedTitles.add(expertise.title),
      );

      await tester.tap(dialNode('Flutter Development'));
      await settle(tester);

      expect(find.text('Opened Flutter Development'), findsOneWidget);
      expect(openedTitles, ['Flutter Development']);
    },
  );

  testWidgets('should show the next expertise when the next arrow is tapped', (
    tester,
  ) async {
    await pumpOrbit(tester, mobileSize);

    await tester.tap(find.byTooltip('Next expertise'));
    await settle(tester);

    expect(find.text('Native Android'), findsOneWidget);
  });

  testWidgets(
    'should show the last expertise when the previous arrow is tapped on the '
    'first',
    (tester) async {
      await pumpOrbit(tester, mobileSize);

      await tester.tap(find.byTooltip('Previous expertise'));
      await settle(tester);

      expect(find.text('Design Systems'), findsOneWidget);
    },
  );

  testWidgets(
    'should keep the same height when an expertise with a longer title is '
    'shown',
    (tester) async {
      final shortTitleSize = await pumpOrbit(tester, mobileSize);

      for (var turn = 0; turn < 3; turn++) {
        await tester.tap(find.byTooltip('Next expertise'));
        await settle(tester);
      }

      expect(
        find.text('Mobile Architecture and Clean Code Practices'),
        findsOneWidget,
      );
      expect(tester.getSize(find.byType(ExpertiseOrbitWidget)), shortTitleSize);
    },
  );

  testWidgets(
    'should keep the name in the middle when expertises with names of '
    'different lengths are shown',
    (tester) async {
      await pumpOrbit(tester, mobileSize);
      final middle = mobileSize.width / 2;

      expect(tester.getCenter(find.text('Flutter Development')).dx, middle);

      for (var turn = 0; turn < 2; turn++) {
        await tester.tap(find.byTooltip('Next expertise'));
        await settle(tester);
      }

      expect(tester.getCenter(find.text('Testing')).dx, middle);
    },
  );
}
