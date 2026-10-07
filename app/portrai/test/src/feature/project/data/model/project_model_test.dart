import 'package:flutter_test/flutter_test.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:portrai/src/feature/project/data/model/project_model.dart';

import '../../../../../mock/feature/project/test_data/project_test_data.dart';

void main() {
  final json = createProjectJson();

  group('ProjectModel', () {
    test('should deserialize all fields when JSON is valid', () {
      final model = ProjectModel.fromJson(json);

      expect(model.id, 'port-rai');
      expect(model.title, 'PortRai 🚀');
      expect(model.teamSize, 3);
      expect(model.technologies, ['Flutter', 'Dart']);
      expect(model.locale, 'en');
    });

    test('should preserve all fields when serialized and deserialized', () {
      final model = ProjectModel.fromJson(json);

      expect(model.toJson(), json);
      expect(ProjectModel.fromJson(model.toJson()).toJson(), json);
    });

    test('should reject missing required fields when deserializing JSON', () {
      final incomplete = Map<String, dynamic>.of(json)..remove('title');

      expect(
        () => ProjectModel.fromJson(incomplete),
        throwsA(isA<CheckedFromJsonException>()),
      );
    });
  });
}
