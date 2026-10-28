import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/job_opening/presentation/widget/_widget.dart';

import '../../../../../mock/feature/job_opening/domain/entity/job_opening_entity_fixture.dart';
import '../../../../../util/date_test_util.dart';
import '../../../../../util/test_wrapper_widget.dart';

void main() {
  Future<void> pumpPosted(WidgetTester tester, {required int daysAgo}) {
    return tester.pumpWidget(
      TestWidgetWrapper(
        child: JobOpeningPostedWidget(
          jobOpening: jobOpeningEntityFixture(
            publishedAt: calendarDaysAgo(daysAgo),
          ),
        ),
      ),
    );
  }

  testWidgets('should highlight an opening posted in the last 3 days', (
    tester,
  ) async {
    await pumpPosted(tester, daysAgo: 3);

    expect(find.text('Posted 3 days ago'), findsOneWidget);
    expect(find.byIcon(Icons.auto_awesome_rounded), findsOneWidget);
  });

  testWidgets('should show an older opening without the highlight', (
    tester,
  ) async {
    await pumpPosted(tester, daysAgo: 4);

    expect(find.text('Posted 4 days ago'), findsOneWidget);
    expect(find.byIcon(Icons.schedule_rounded), findsOneWidget);
  });
}
