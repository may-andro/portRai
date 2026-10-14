import 'dart:convert';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/expertise/domain/_domain.dart';
import 'package:portrai/src/feature/expertise/presentation/screen/expertise/lottie/_lottie.dart';

void main() {
  const builder = ExpertiseStatsLottieBuilder();
  const expertise = ExpertiseEntity(
    image: 'https://example.com/flutter.png',
    title: 'Mobile Development',
    skills: [
      SkillEntity(name: 'Flutter', level: 'expert', years: 6),
      SkillEntity(name: 'Kotlin', level: 'intermediate', years: 3),
      SkillEntity(name: 'Swift'),
    ],
  );
  const color = Color(0xFF3355FF);
  const accent = Color(0xFF55FF33);

  Map<String, dynamic> decode(ExpertiseEntity entity) {
    final bytes = builder.build(entity, color: color, accent: accent);
    return jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
  }

  group('ExpertiseStatsLottieBuilder', () {
    test('should create one bar per skill plus a baseline when building', () {
      final layers = decode(expertise)['layers'] as List<dynamic>;

      expect(layers, hasLength(1 + expertise.skills.length));
    });

    test('should be deterministic when built twice for the same expertise', () {
      expect(
        builder.build(expertise, color: color, accent: accent),
        builder.build(expertise, color: color, accent: accent),
      );
    });

    test('should only draw the baseline when the expertise has no skills', () {
      const empty = ExpertiseEntity(image: '', title: 'Empty', skills: []);

      expect(decode(empty)['layers'], hasLength(1));
    });
  });
}
