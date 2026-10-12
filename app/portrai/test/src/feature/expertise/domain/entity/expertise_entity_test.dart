import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/expertise/domain/entity/skill_entity.dart';
import 'package:portrai/src/feature/expertise/expertise.dart';

void main() {
  const expertise = ExpertiseEntity(
    image: 'https://example.com/flutter.png',
    title: 'Flutter Development',
    skills: [
      SkillEntity(name: 'Flutter SDK'),
      SkillEntity(name: 'State Management'),
    ],
  );

  group('ExpertiseEntity', () {
    test('should compare equal when all expertise fields match', () {
      expect(expertise, expertise);
      expect(
        expertise,
        const ExpertiseEntity(
          image: 'https://example.com/flutter.png',
          title: 'Flutter Development',
          skills: [
            SkillEntity(name: 'Flutter SDK'),
            SkillEntity(name: 'State Management'),
          ],
        ),
      );
      expect(expertise.hashCode, expertise.hashCode);
    });

    test('should not compare equal when a field differs', () {
      expect(
        expertise,
        isNot(
          const ExpertiseEntity(
            image: 'https://example.com/android.png',
            title: 'Flutter Development',
            skills: [
              SkillEntity(name: 'Flutter SDK'),
              SkillEntity(name: 'State Management'),
            ],
          ),
        ),
      );
    });
  });
}
