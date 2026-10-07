import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/testimonial/domain/entity/testimonial_entity.dart';

void main() {
  TestimonialEntity createEntity({String company = 'Acme'}) {
    return TestimonialEntity(
      id: 'john-doe',
      name: 'John Doe',
      position: 'Engineering Manager',
      company: company,
      testimonial: 'Rai consistently delivers thoughtful Flutter work.',
      date: '2025',
      profileImage: 'https://example.com/john.png',
      companyLogo: 'https://example.com/acme.png',
      linkedinProfile: 'https://linkedin.com/in/john-doe',
      projectContext: 'Portfolio App',
    );
  }

  group('TestimonialEntity', () {
    test('should compare equal when all testimonial fields match', () {
      expect(createEntity(), createEntity());
      expect(createEntity().hashCode, createEntity().hashCode);
    });

    test('should not compare equal when a field differs', () {
      expect(createEntity(), isNot(createEntity(company: 'Globex')));
    });
  });
}
