import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/testimonial/data/mapper/testimonial_mapper.dart';

import '../../../../../mock/feature/testimonial/test_data/testimonial_test_data.dart';

void main() {
  final locale = AppLocale('nl');
  final mapper = TestimonialMapper(appLocale: locale);
  final entity = createTestimonialEntity();

  group('TestimonialMapper', () {
    test(
      'should map an entity to a model and add the configured locale when mapping from',
      () {
        final result = mapper.from(entity);

        expect(result.id, entity.id);
        expect(result.name, entity.name);
        expect(result.locale, 'nl');
      },
    );

    test('should map a model to an entity when mapping to', () {
      final model = createTestimonialModel(locale: 'nl');

      expect(mapper.to(model), entity);
    });
  });
}
