import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/experience/data/cache/experience_cache.dart';
import 'package:portrai/src/feature/experience/data/model/experience_model.dart';

void main() {
  group('ExperienceCache', () {
    final cache = ExperienceCache();
    final model = ExperienceModel(
      company: 'Acme',
      position: 'Engineer',
      location: 'Amsterdam',
      startDate: '2024-01-01',
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
      locale: 'en',
    );

    test(
      'should serialize boolean and lists for storage when writing a model',
      () {
        final result = cache.serialize(model);

        expect(result['current'], 1);
        expect(result['responsibilities'], '["Coding"]');
        expect(result['achievements'], '["Shipped"]');
        expect(result['technologies'], '["Dart"]');
        expect(result['id'], model.id);
        expect(result['locale'], model.locale);
      },
    );

    test('should restore boolean and lists when reading a stored model', () {
      final stored = cache.serialize(model);

      final result = cache.deserialize(stored);

      expect(result.toJson(), model.toJson());
    });

    test('should restore false when the stored current value is zero', () {
      final stored = cache.serialize(model)..['current'] = 0;

      expect(cache.deserialize(stored).current, isFalse);
    });

    test('should use ID and locale as the composite key when caching', () {
      expect(cache.primaryKeyColumns, ['id', 'locale']);
    });
  });
}
