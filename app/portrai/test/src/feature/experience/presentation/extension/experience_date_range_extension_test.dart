import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/experience/domain/_domain.dart';
import 'package:portrai/src/feature/experience/presentation/extension/experience_date_range_extension.dart';

import '../../../../../util/test_wrapper_widget.dart';

void main() {
  ExperienceEntity createEntity({DateTime? endDate}) {
    return ExperienceEntity(
      company: 'Acme',
      position: 'Engineer',
      location: 'Amsterdam',
      startDate: DateTime(2024),
      endDate: endDate,
      current: endDate == null,
      employmentType: 'Full-time',
      description: 'Builds products',
      longDescription: 'Builds products for customers',
      responsibilities: const ['Coding'],
      achievements: const ['Shipped'],
      technologies: const ['Dart'],
      companyLogo: 'acme.png',
      url: null,
      id: 'acme-engineer',
    );
  }

  Future<String> formatRange(
    WidgetTester tester,
    ExperienceEntity entity,
  ) async {
    late String result;
    await tester.pumpWidget(
      TestWidgetWrapper(
        child: Builder(
          builder: (context) {
            result = entity.formattedDateRange(context);
            return const SizedBox();
          },
        ),
      ),
    );
    return result;
  }

  group('ExperienceDateRangeExtension', () {
    testWidgets('should format both dates when the experience has ended', (
      tester,
    ) async {
      final result = await formatRange(
        tester,
        createEntity(endDate: DateTime(2025, 3)),
      );

      expect(result, 'Jan 2024 - Mar 2025');
    });

    testWidgets(
      'should use the localized present label when there is no end date',
      (tester) async {
        final result = await formatRange(tester, createEntity());

        expect(result, 'Jan 2024 - Present');
      },
    );
  });
}
