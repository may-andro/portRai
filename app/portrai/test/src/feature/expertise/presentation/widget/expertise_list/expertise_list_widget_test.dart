import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/expertise/domain/entity/expertise_entity.dart';
import 'package:portrai/src/feature/expertise/domain/entity/skill_entity.dart';
import 'package:portrai/src/feature/expertise/presentation/widget/expertise_list/expertise_list_widget.dart';

import '../../../../../../util/test_wrapper_widget.dart';

void main() {
  List<ExpertiseEntity> createExpertiseList(int count) {
    return List.generate(
      count,
      (index) => ExpertiseEntity(
        image: 'https://example.com/$index.png',
        title: 'Expertise $index',
        skills: [SkillEntity(name: 'Skill $index')],
      ),
    );
  }

  Future<void> pumpExpertiseListWidget(
    WidgetTester tester, {
    required List<ExpertiseEntity> expertise,
    required Size size,
    Duration settleDuration = const Duration(seconds: 2),
    ValueChanged<ExpertiseEntity>? onClicked,
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
        child: SingleChildScrollView(
          child: ExpertiseListWidget(
            allExpertise: expertise,
            isVisible: true,
            onClicked: onClicked ?? (_) {},
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump(settleDuration);
  }

  group('ExpertiseListWidget', () {
    testWidgets('should render every expertise card when shown on mobile', (
      tester,
    ) async {
      await pumpExpertiseListWidget(
        tester,
        expertise: createExpertiseList(7),
        size: const Size(390, 844),
      );

      expect(find.byType(DSHoverableContainerWidget), findsNWidgets(7));
      expect(find.text('Expertise 6'), findsOneWidget);
    });

    testWidgets('should show the skills of a card when it is rendered', (
      tester,
    ) async {
      await pumpExpertiseListWidget(
        tester,
        expertise: createExpertiseList(1),
        size: const Size(390, 844),
      );

      expect(find.text('Skill 0'), findsOneWidget);
    });

    testWidgets('should report the tapped expertise when a card is tapped', (
      tester,
    ) async {
      final expertise = createExpertiseList(2);
      final openedExpertise = <ExpertiseEntity>[];
      await pumpExpertiseListWidget(
        tester,
        expertise: expertise,
        size: const Size(1440, 1024),
        onClicked: openedExpertise.add,
      );

      await tester.tap(find.text('Expertise 1'));
      await tester.pump();

      expect(openedExpertise, [expertise[1]]);
    });

    testWidgets(
      'should collapse extra skills into a counter when there are more than eight',
      (tester) async {
        await pumpExpertiseListWidget(
          tester,
          expertise: [
            ExpertiseEntity(
              image: 'https://example.com/a.png',
              title: 'Many',
              skills: [for (var i = 0; i < 11; i++) SkillEntity(name: 'S$i')],
            ),
          ],
          size: const Size(1440, 1024),
        );

        expect(find.text('S7'), findsOneWidget);
        expect(find.text('S8'), findsNothing);
        expect(find.text('+3'), findsOneWidget);
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

        expect(find.byType(DSHoverableContainerWidget), findsNothing);
      },
    );
  });
}
