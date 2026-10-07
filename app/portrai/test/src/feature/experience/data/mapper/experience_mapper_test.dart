import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/experience/data/mapper/experience_mapper.dart';
import 'package:portrai/src/feature/experience/data/model/experience_model.dart';
import 'package:portrai/src/feature/experience/domain/entity/experience_entity.dart';

void main() {
  final startDate = DateTime(2024);
  final endDate = DateTime(2025, 3);
  final locale = AppLocale('nl');
  final mapper = ExperienceMapper(appLocale: locale);

  final entity = ExperienceEntity(
    company: 'Acme',
    position: 'Engineer',
    location: 'Amsterdam',
    startDate: startDate,
    endDate: endDate,
    current: false,
    employmentType: 'Full-time',
    description: 'Builds products',
    longDescription: 'Builds products for customers',
    responsibilities: const ['Coding'],
    achievements: const ['Shipped'],
    technologies: const ['Dart'],
    companyLogo: 'acme.png',
    url: 'https://acme.example',
    id: 'acme-engineer',
  );

  group('ExperienceMapper', () {
    test(
      'should map an entity to a model and add the configured locale when mapping from',
      () {
        final result = mapper.from(entity);

        expect(result.company, entity.company);
        expect(result.startDate, '2024-01-01');
        expect(result.endDate, '2025-03-01');
        expect(result.locale, 'nl');
        expect(result.id, entity.id);
      },
    );

    test(
      'should map a model to an entity and parse formatted dates when mapping to',
      () {
        final model = ExperienceModel(
          company: 'Acme',
          position: 'Engineer',
          location: 'Amsterdam',
          startDate: '2024-01-01',
          endDate: '2025-03-01',
          current: false,
          employmentType: 'Full-time',
          description: 'Builds products',
          longDescription: 'Builds products for customers',
          responsibilities: const ['Coding'],
          achievements: const ['Shipped'],
          technologies: const ['Dart'],
          companyLogo: 'acme.png',
          url: 'https://acme.example',
          id: 'acme-engineer',
          locale: 'nl',
        );

        expect(mapper.to(model), entity);
      },
    );
  });
}
