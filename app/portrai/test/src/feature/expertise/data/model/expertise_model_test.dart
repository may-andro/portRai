import 'package:flutter_test/flutter_test.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:portrai/src/feature/expertise/data/model/expertise_model.dart';

void main() {
  final json = <String, dynamic>{
    'image': 'https://example.com/flutter.png',
    'title': 'Flutter Development',
    'skills': ['Flutter SDK', 'State Management'],
    'locale': 'en',
  };

  group('ExpertiseModel', () {
    test('should deserialize all fields when JSON is valid', () {
      final model = ExpertiseModel.fromJson(json);

      expect(model.image, 'https://example.com/flutter.png');
      expect(model.title, 'Flutter Development');
      expect(model.skills, ['Flutter SDK', 'State Management']);
      expect(model.locale, 'en');
    });

    test('should preserve all fields when serialized and deserialized', () {
      final model = ExpertiseModel.fromJson(json);

      expect(model.toJson(), json);
      expect(ExpertiseModel.fromJson(model.toJson()).toJson(), json);
    });

    test('should reject missing required fields when deserializing JSON', () {
      final incomplete = Map<String, dynamic>.of(json)..remove('title');

      expect(
        () => ExpertiseModel.fromJson(incomplete),
        throwsA(isA<CheckedFromJsonException>()),
      );
    });
  });
}
