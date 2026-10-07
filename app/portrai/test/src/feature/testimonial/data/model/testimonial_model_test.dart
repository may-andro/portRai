import 'package:flutter_test/flutter_test.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:portrai/src/feature/testimonial/data/model/testimonial_model.dart';

void main() {
  final json = <String, dynamic>{
    'id': 'john-doe',
    'name': 'John Doe',
    'position': 'Engineering Manager',
    'company': 'Acme',
    'testimonial': 'Rai consistently delivers thoughtful Flutter work.',
    'date': '2025',
    'profileImage': 'https://example.com/john.png',
    'companyLogo': 'https://example.com/acme.png',
    'linkedinProfile': 'https://linkedin.com/in/john-doe',
    'projectContext': 'Portfolio App',
    'locale': 'en',
  };

  group('TestimonialModel', () {
    test('should deserialize all fields when JSON is valid', () {
      final model = TestimonialModel.fromJson(json);

      expect(model.id, 'john-doe');
      expect(model.name, 'John Doe');
      expect(model.company, 'Acme');
      expect(model.projectContext, 'Portfolio App');
      expect(model.locale, 'en');
    });

    test('should preserve all fields when serialized and deserialized', () {
      final model = TestimonialModel.fromJson(json);

      expect(model.toJson(), json);
      expect(TestimonialModel.fromJson(model.toJson()).toJson(), json);
    });

    test('should reject missing required fields when deserializing JSON', () {
      final incomplete = Map<String, dynamic>.of(json)..remove('name');

      expect(
        () => TestimonialModel.fromJson(incomplete),
        throwsA(isA<CheckedFromJsonException>()),
      );
    });
  });
}
