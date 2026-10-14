import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/expertise/domain/_domain.dart';
import 'package:portrai/src/feature/expertise/presentation/screen/expertise/bloc/_bloc.dart';
import 'package:portrai/src/feature/expertise/presentation/screen/expertise/widget/_widget.dart';

import '../../../../../../../util/test_wrapper_widget.dart';

class _MockExpertiseBloc extends MockBloc<ExpertiseEvent, ExpertiseState>
    implements ExpertiseBloc {}

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

    final bloc = _MockExpertiseBloc();
    whenListen(
      bloc,
      const Stream<ExpertiseState>.empty(),
      initialState: const ExpertiseState(),
    );

    await tester.pumpWidget(
      TestWidgetWrapper(
        child: BlocProvider<ExpertiseBloc>.value(
          value: bloc,
          child: const Scaffold(body: ContentWidget(expertise: expertise)),
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
  });
}
