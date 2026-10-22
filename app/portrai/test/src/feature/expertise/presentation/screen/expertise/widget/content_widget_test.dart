import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/expertise/domain/_domain.dart';
import 'package:portrai/src/feature/expertise/presentation/screen/expertise/bloc/_bloc.dart';
import 'package:portrai/src/feature/expertise/presentation/screen/expertise/widget/_widget.dart';
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:portrai/src/widget/screen_content_widget.dart';

import '../../../../../../../mock/feature/expertise/presentation/screen/expertise/bloc/mock_expertise_bloc.dart';
import '../../../../../../../util/test_wrapper_widget.dart';

void main() {
  const expertise = ExpertiseEntity(
    image: 'https://example.com/flutter.png',
    title: 'Mobile Development',
    summary: 'Apps for every platform.',
    skills: [
      SkillEntity(
        name: 'Flutter',
        description: 'UI toolkit.',
        level: 'expert',
        years: 6,
        lastUsed: 2026,
      ),
      SkillEntity(name: 'Kotlin', level: 'intermediate'),
      SkillEntity(name: 'Swift'),
    ],
  );

  Future<void> pumpContent(WidgetTester tester, Size size) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      TestWidgetWrapper(
        child: ScreenFooterProviderWidget(
          footer: const Text('footer'),
          child: BlocProvider<ExpertiseBloc>.value(
            value: MockExpertiseBloc()..stubState(const ExpertiseState()),
            child: const ContentWidget(expertise: expertise),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
  }

  Future<void> disposeContent(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  }

  group('ContentWidget', () {
    testWidgets('should show the title and every skill when on mobile', (
      tester,
    ) async {
      await pumpContent(tester, const Size(390, 844));

      expect(find.text('Mobile Development'), findsOneWidget);
      expect(find.text('Flutter'), findsOneWidget);
      expect(find.text('Apps for every platform.'), findsOneWidget);
      expect(find.text('UI toolkit.'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await disposeContent(tester);
    });

    testWidgets('should show the title and every skill when on desktop', (
      tester,
    ) async {
      await pumpContent(tester, const Size(1400, 900));

      expect(find.text('Mobile Development'), findsOneWidget);
      expect(find.text('Swift'), findsOneWidget);
      expect(find.text('SKILLS'), findsOneWidget);
      expect(find.text('EXPERT-LEVEL'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await disposeContent(tester);
    });

    testWidgets(
      'should end the shared scroll view with the provided footer when shown',
      (tester) async {
        await pumpContent(tester, const Size(1400, 900));

        final scrollView = find.byType(CustomScrollView);
        expect(scrollView, findsOneWidget);
        expect(
          find.descendant(of: scrollView, matching: find.text('SKILLS')),
          findsOneWidget,
        );
        await tester.scrollUntilVisible(
          find.text('footer'),
          500,
          scrollable: find
              .descendant(of: scrollView, matching: find.byType(Scrollable))
              .first,
        );
        expect(
          find.descendant(of: scrollView, matching: find.text('footer')),
          findsOneWidget,
        );
        final lastSliver = tester
            .widget<CustomScrollView>(scrollView)
            .slivers
            .last;
        expect(
          lastSliver,
          isA<SliverToBoxAdapter>().having(
            (sliver) => (sliver.child! as Text).data,
            'footer text',
            'footer',
          ),
        );
        expect(find.byType(FooterWidget), findsNothing);
        await disposeContent(tester);
      },
    );
  });
}
