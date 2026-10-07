import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/project/data/mapper/project_mapper.dart';

import '../../../../../mock/feature/project/test_data/project_test_data.dart';

void main() {
  final locale = AppLocale('nl');
  final mapper = ProjectMapper(appLocale: locale);
  final entity = createProjectEntity();

  group('ProjectMapper', () {
    test(
      'should map an entity to a model and add the configured locale when mapping from',
      () {
        final result = mapper.from(entity);

        expect(result.id, entity.id);
        expect(result.title, entity.title);
        expect(result.startDate, '2024-01-01T00:00:00.000');
        expect(result.endDate, '2025-03-01T00:00:00.000');
        expect(result.locale, 'nl');
      },
    );

    test(
      'should map a model to an entity and parse formatted dates when mapping to',
      () {
        final model = createProjectModel(locale: 'nl');

        expect(mapper.to(model), entity);
      },
    );
  });
}
