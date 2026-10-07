import 'package:flutter_test/flutter_test.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:portrai/src/feature/service/data/model/service_model.dart';

void main() {
  final json = <String, dynamic>{
    'title': 'App Development',
    'description': 'Beautiful apps',
    'image': 'service.png',
    'detail': 'Detailed service description',
    'locale': 'en',
  };

  group('ServiceModel', () {
    test('should deserialize all fields when JSON is valid', () {
      final model = ServiceModel.fromJson(json);

      expect(model.title, 'App Development');
      expect(model.description, 'Beautiful apps');
      expect(model.image, 'service.png');
      expect(model.detail, 'Detailed service description');
      expect(model.locale, 'en');
    });

    test('should preserve all fields when serialized and deserialized', () {
      final model = ServiceModel.fromJson(json);

      expect(model.toJson(), json);
      expect(ServiceModel.fromJson(model.toJson()).toJson(), json);
    });

    test('should reject missing required fields when deserializing JSON', () {
      final incomplete = Map<String, dynamic>.of(json)..remove('title');

      expect(
        () => ServiceModel.fromJson(incomplete),
        throwsA(isA<CheckedFromJsonException>()),
      );
    });
  });
}
