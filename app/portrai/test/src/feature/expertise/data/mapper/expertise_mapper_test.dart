import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/expertise/data/mapper/expertise_mapper.dart';
import 'package:portrai/src/feature/expertise/data/model/expertise_model.dart';
import 'package:portrai/src/feature/expertise/data/model/skill_model.dart';
import 'package:portrai/src/feature/expertise/domain/entity/expertise_entity.dart';
import 'package:portrai/src/feature/expertise/domain/entity/skill_entity.dart';

void main() {
  const entity = ExpertiseEntity(
    image: 'https://example.com/flutter.png',
    title: 'Flutter Development',
    skills: [
      SkillEntity(name: 'Flutter SDK'),
      SkillEntity(name: 'State Management'),
    ],
  );
  final mapper = ExpertiseMapper(appLocale: AppLocale('nl'));

  group('ExpertiseMapper', () {
    test(
      'should map an entity to a model and add the configured locale when mapping from',
      () {
        final result = mapper.from(entity);

        expect(result.image, entity.image);
        expect(result.title, entity.title);
        expect(result.skills.map((s) => s.name), entity.skillNames);
        expect(result.locale, 'nl');
      },
    );

    test('should map a model to an entity when mapping to a domain entity', () {
      final model = ExpertiseModel(
        image: 'https://example.com/flutter.png',
        title: 'Flutter Development',
        skills: [
          SkillModel(name: 'Flutter SDK'),
          SkillModel(name: 'State Management'),
        ],
        locale: 'nl',
      );

      expect(mapper.to(model), entity);
    });
  });
}
