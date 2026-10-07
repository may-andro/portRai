import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/experience/experience.dart';

void main() {
  ExperienceEntity createEntity({String company = 'Acme'}) {
    return ExperienceEntity(
      company: company,
      position: 'Engineer',
      location: 'Amsterdam',
      startDate: DateTime(2024),
      endDate: null,
      current: true,
      employmentType: 'Full-time',
      description: 'Builds products',
      longDescription: 'Builds products for customers',
      responsibilities: const ['Coding'],
      achievements: const ['Shipped'],
      technologies: const ['Dart'],
      companyLogo: 'acme.png',
      url: null,
      id: 'acme-engineer',
    );
  }

  group('ExperienceEntity', () {
    test('should compare equal when all experience fields match', () {
      expect(createEntity(), createEntity());
      expect(createEntity().hashCode, createEntity().hashCode);
    });

    test('should not compare equal when a field differs', () {
      expect(createEntity(), isNot(createEntity(company: 'Other')));
    });
  });
}
