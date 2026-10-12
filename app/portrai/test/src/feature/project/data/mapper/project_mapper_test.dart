import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/project/data/mapper/project_mapper.dart';
import 'package:portrai/src/feature/project/domain/entity/project_market_entity.dart';
import 'package:portrai/src/feature/project/domain/entity/project_metric_entity.dart';

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

    test('should keep markets and metrics when mapping both ways', () {
      final withMarkets = createProjectEntity(
        experienceId: 'mediamarkt',
        markets: const [
          ProjectMarketEntity(
            country: 'Germany',
            latitude: 51.1657,
            longitude: 10.4515,
            appStore: 'https://example.com/app',
          ),
        ],
        metrics: const [ProjectMetricEntity(label: 'Downloads', value: '1M+')],
      );

      final model = mapper.from(withMarkets);

      expect(model.experienceId, 'mediamarkt');
      expect(model.markets.single.country, 'Germany');
      expect(model.markets.single.latitude, 51.1657);
      expect(model.metrics.single.value, '1M+');
      expect(mapper.to(model), withMarkets);
    });
  });
}
