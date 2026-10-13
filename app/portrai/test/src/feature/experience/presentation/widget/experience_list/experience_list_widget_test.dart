import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/experience/domain/_domain.dart';
import 'package:portrai/src/feature/experience/presentation/widget/experience_list/experience_list.dart';

import '../../../../../../util/test_wrapper_widget.dart';

void main() {
  ExperienceEntity experience(int index, {DateTime? endDate}) {
    return ExperienceEntity(
      company: 'Company $index',
      position: 'Position $index',
      location: 'Madrid',
      startDate: DateTime(2015 + index),
      endDate: endDate,
      current: endDate == null,
      employmentType: 'Full-time',
      description: 'Description $index',
      longDescription: 'Long description $index',
      responsibilities: const ['Lead the team'],
      achievements: const [],
      technologies: const ['Flutter'],
      companyLogo: '',
      url: null,
      id: 'id_$index',
    );
  }

  final experiences = [
    experience(0, endDate: DateTime(2018)),
    experience(1, endDate: DateTime(2020)),
    experience(2),
  ];

  Future<void> pumpList(
    WidgetTester tester,
    Size size, {
    int? visibleItemsCount,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      TestWidgetWrapper(
        child: SingleChildScrollView(
          child: ExperienceListWidget(
            experiences: experiences,
            isVisible: true,
            visibleItemsCount: visibleItemsCount,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 3));
  }

  const sizes = {
    'mobile': Size(390, 844),
    'tablet': Size(820, 1180),
    'desktop': Size(1440, 900),
  };

  for (final entry in sizes.entries) {
    testWidgets(
      'should render every experience without errors when on ${entry.key}',
      (tester) async {
        await pumpList(tester, entry.value);

        expect(find.text('Position 0'), findsOneWidget);
        expect(find.text('Position 2'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'should limit the experiences when visible count is set on mobile',
    (tester) async {
      await pumpList(tester, sizes['mobile']!, visibleItemsCount: 2);

      expect(find.text('Position 1'), findsOneWidget);
      expect(find.text('Position 2'), findsNothing);
    },
  );

  testWidgets('should show the start year watermark when on desktop', (
    tester,
  ) async {
    await pumpList(tester, sizes['desktop']!);

    expect(find.text('2015'), findsOneWidget);
  });

  testWidgets('should reveal only the description when a card is tapped', (
    tester,
  ) async {
    await pumpList(tester, sizes['desktop']!);
    final description = find.text('Description 0');
    expect(description, findsNothing);

    await tester.tap(find.text('Position 0'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(description, findsOneWidget);
    expect(find.text('Lead the team'), findsNothing);
    expect(find.text('Flutter'), findsNothing);
  });

  for (final size in ['mobile', 'tablet']) {
    testWidgets(
      'should navigate instead of expanding when a card is tapped on $size',
      (tester) async {
        await pumpList(tester, sizes[size]!);

        await tester.tap(find.text('Position 0'));
        await tester.pump();

        expect(find.text('Description 0'), findsNothing);
        expect(tester.takeException(), isNotNull);
      },
    );
  }
}
