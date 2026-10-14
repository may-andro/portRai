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

  group('ExpertiseEntity stats', () {
    const detailed = ExpertiseEntity(
      image: 'https://example.com/flutter.png',
      title: 'Flutter Development',
      skills: [
        SkillEntity(name: 'Flutter', level: 'expert', years: 8, lastUsed: 2026),
        SkillEntity(name: 'Dart', level: 'expert', years: 6, lastUsed: 2025),
        SkillEntity(name: 'FFI', level: 'advanced'),
      ],
    );

    test('should count the expert skills when asking for the expert count', () {
      expect(detailed.expertSkillCount, 2);
    });

    test('should return the longest and latest values when they are known', () {
      expect(detailed.maxYears, 8);
      expect(detailed.latestYearUsed, 2026);
    });

    test('should return null when no skill has years or last used', () {
      const bare = ExpertiseEntity(
        image: '',
        title: 'Bare',
        skills: [SkillEntity(name: 'Swift')],
      );

      expect(bare.maxYears, isNull);
      expect(bare.latestYearUsed, isNull);
    });
  });
}
