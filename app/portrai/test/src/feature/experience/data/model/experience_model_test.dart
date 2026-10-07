import 'package:flutter_test/flutter_test.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:portrai/src/feature/experience/data/model/experience_model.dart';

void main() {
  final json = <String, dynamic>{
    'company': 'Acme',
    'position': 'Engineer',
    'location': 'Amsterdam',
    'startDate': '2024-01-01',
    'endDate': null,
    'current': true,
    'employmentType': 'Full-time',
    'description': 'Builds products',
    'longDescription': 'Builds products for customers',
    'responsibilities': ['Coding'],
    'achievements': ['Shipped'],
    'technologies': ['Dart'],
    'companyLogo': 'acme.png',
    'url': null,
    'id': 'acme-engineer',
    'locale': 'en',
  };

  group('ExperienceModel', () {
    test('should deserialize all fields when JSON is valid', () {
      final model = ExperienceModel.fromJson(json);

      expect(model.company, 'Acme');
      expect(model.startDate, '2024-01-01');
      expect(model.endDate, isNull);
      expect(model.current, isTrue);
      expect(model.responsibilities, ['Coding']);
      expect(model.achievements, ['Shipped']);
      expect(model.technologies, ['Dart']);
      expect(model.url, isNull);
      expect(model.locale, 'en');
    });

    test('should preserve all fields when serialized and deserialized', () {
      final model = ExperienceModel.fromJson(json);

      expect(model.toJson(), json);
      expect(ExperienceModel.fromJson(model.toJson()).toJson(), json);
    });

    test('should reject missing required fields when deserializing JSON', () {
      final incomplete = Map<String, dynamic>.of(json)..remove('company');

      expect(
        () => ExperienceModel.fromJson(incomplete),
        throwsA(isA<CheckedFromJsonException>()),
      );
    });
  });
}
