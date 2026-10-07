import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/project/presentation/extension/project_date_range_extension.dart';
import 'package:portrai/src/feature/project/project.dart';

import '../../../../../mock/feature/project/test_data/project_test_data.dart';
import '../../../../../util/test_wrapper_widget.dart';

void main() {
  ProjectEntity createEntity({DateTime? endDate}) {
    return createProjectEntity(endDate: endDate);
  }

  Future<String> formatRange(WidgetTester tester, ProjectEntity entity) async {
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

  group('ProjectDateRangeExtension', () {
    testWidgets('should format both dates when the project has ended', (
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
        final result = await formatRange(
          tester,
          createProjectEntity(hasEndDate: false),
        );

        expect(result, 'Jan 2024 - Present');
      },
    );
  });
}
