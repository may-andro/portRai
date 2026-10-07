import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/project/presentation/screen/project/dto/_dto.dart';
import 'package:portrai/src/feature/project/presentation/screen/project/extension/_extension.dart';

import '../../../../../../../mock/feature/project/test_data/project_test_data.dart';

void main() {
  group('ProjectEntityExtension', () {
    test('should expose project sections in the expected order', () {
      final sections = createProjectEntity().sections;

      expect(sections, hasLength(6));
      expect(sections[0], isA<IntroSectionDTO>());
      expect(sections[1], isA<OverviewSectionDTO>());
      expect(sections[2], isA<TechnologiesSectionDTO>());
      expect(sections[3], isA<AchievementsSectionDTO>());
      expect(sections[4], isA<KeyFeaturesSectionDTO>());
      expect(sections[5], isA<AvailabilitiesSectionDTO>());
    });
  });
}
