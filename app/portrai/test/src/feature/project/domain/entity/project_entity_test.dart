import 'package:flutter_test/flutter_test.dart';

import '../../../../../mock/feature/project/test_data/project_test_data.dart';

void main() {
  group('ProjectEntity', () {
    test('should compare equal when all project fields match', () {
      expect(createProjectEntity(), createProjectEntity());
      expect(createProjectEntity().hashCode, createProjectEntity().hashCode);
    });

    test('should not compare equal when a field differs', () {
      expect(
        createProjectEntity(),
        isNot(createProjectEntity(title: 'Other Project')),
      );
    });
  });
}
