import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/service/data/mapper/service_mapper.dart';
import 'package:portrai/src/feature/service/data/model/service_model.dart';
import 'package:portrai/src/feature/service/domain/entity/service_entity.dart';

void main() {
  const entity = ServiceEntity(
    image: 'service.png',
    title: 'App Development',
    description: 'Beautiful apps',
    detail: 'Detailed service description',
  );
  final mapper = ServiceMapper(appLocale: AppLocale('nl'));

  group('ServiceMapper', () {
    test(
      'should map an entity to a model and add the configured locale when mapping from',
      () {
        final result = mapper.from(entity);

        expect(result.title, entity.title);
        expect(result.description, entity.description);
        expect(result.image, entity.image);
        expect(result.detail, entity.detail);
        expect(result.locale, 'nl');
      },
    );

    test('should map a model to an entity when mapping to', () {
      final model = ServiceModel(
        title: 'App Development',
        description: 'Beautiful apps',
        image: 'service.png',
        detail: 'Detailed service description',
        locale: 'nl',
      );

      expect(mapper.to(model), entity);
    });
  });
}
