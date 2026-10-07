import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/expertise/domain/entity/expertise_entity.dart';
import 'package:portrai/src/feature/expertise/presentation/widget/expertise_list/expertise_list_widget.dart';

import '../../../../../../util/test_wrapper_widget.dart';

void main() {
  List<ExpertiseEntity> createExpertiseList(int count) {
    return List.generate(
      count,
      (index) => ExpertiseEntity(
        image: 'https://example.com/$index.png',
        title: 'Expertise $index',
        skills: ['Skill $index'],
      ),
    );
  }

  Future<void> pumpExpertiseListWidget(
    WidgetTester tester, {
    required List<ExpertiseEntity> expertise,
    required Size size,
    Duration settleDuration = const Duration(seconds: 2),
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 1));
    });

    await tester.pumpWidget(
      TestWidgetWrapper(
        child: ExpertiseListWidget(allExpertise: expertise, isVisible: true),
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump(settleDuration);
  }

  group('ExpertiseListWidget', () {
    testWidgets(
      'should render only the first five expertise items when shown on mobile',
      (tester) async {
        await pumpExpertiseListWidget(
          tester,
          expertise: createExpertiseList(7),
          size: const Size(390, 844),
        );

        expect(find.byType(DSExpandableCardWidget), findsNWidgets(5));
        expect(find.text('Expertise 4'), findsOneWidget);
        expect(find.text('Expertise 5'), findsNothing);
      },
    );

    testWidgets(
      'should render all available expertise items when fewer than five are provided on mobile',
      (tester) async {
        await pumpExpertiseListWidget(
          tester,
          expertise: createExpertiseList(3),
          size: const Size(390, 844),
        );

        expect(find.byType(DSExpandableCardWidget), findsNWidgets(3));
        expect(find.text('Expertise 2'), findsOneWidget);
      },
    );

    testWidgets(
      'should show the expertise skills when a mobile card is expanded',
      (tester) async {
        await pumpExpertiseListWidget(
          tester,
          expertise: createExpertiseList(1),
          size: const Size(390, 844),
        );

        await tester.tapAt(
          tester.getCenter(find.byType(DSExpandableCardWidget).first),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('Skill 0'), findsOneWidget);
      },
    );

    testWidgets(
      'should not render any cards when the expertise list is empty on desktop',
      (tester) async {
        await pumpExpertiseListWidget(
          tester,
          expertise: const [],
          size: const Size(1440, 1024),
          settleDuration: Duration.zero,
        );

        expect(find.byType(DSCardWidget), findsNothing);
        expect(find.byType(DSExpandableCardWidget), findsNothing);
      },
    );

    testWidgets(
      'should return the mobile image size when the viewport is mobile',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(390, 844);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        late double imageSize;
        late double expectedImageSize;
        await tester.pumpWidget(
          TestWidgetWrapper(
            child: Builder(
              builder: (context) {
                imageSize = context.expertiseImageSize;
                expectedImageSize = context.space(factor: 8);
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        expect(imageSize, expectedImageSize);
      },
    );

    testWidgets(
      'should return the desktop image size when the viewport is desktop',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(1440, 1024);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        late double imageSize;
        late double expectedImageSize;
        await tester.pumpWidget(
          TestWidgetWrapper(
            child: Builder(
              builder: (context) {
                imageSize = context.expertiseImageSize;
                expectedImageSize = context.space(factor: 5);
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        expect(imageSize, expectedImageSize);
      },
    );
  });
}
