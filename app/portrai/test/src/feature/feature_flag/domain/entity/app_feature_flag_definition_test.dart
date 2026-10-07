import 'package:feature_flag/feature_flag.dart' as layer;
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/feature_flag/domain/entity/app_feature_flag_definition.dart';

import '../../../../../mock/feature/feature_flag/test_data/feature_flag_test_data.dart';

void main() {
  group('AppFeatureFlagDefinition', () {
    test('should expose the expected layer definition when converted', () {
      expect(
        testimonialsDefinition.layerDefinition,
        const layer.FeatureFlagDefinition(
          key: 'feature_testimonials_section',
          defaultValue: false,
        ),
      );
    });

    test('should include all fields in equality when compared', () {
      expect(
        testimonialsDefinition,
        const AppFeatureFlagDefinition(
          key: 'feature_testimonials_section',
          defaultValue: false,
          displayName: 'Testimonials Section',
          description: 'Enables the testimonials section on portfolio page',
        ),
      );
      expect(testimonialsDefinition, isNot(servicesDefinition));
    });
  });
}
