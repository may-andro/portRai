import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/job_opening/presentation/extension/_extension.dart';

import '../../../../../mock/feature/job_opening/domain/entity/job_opening_entity_fixture.dart';

void main() {
  group('JobTypeExtension', () {
    for (final (jobType, formatted) in [
      ('full_time', 'Full time'),
      ('part-time', 'Part time'),
      ('contract', 'Contract'),
      ('', ''),
    ]) {
      test('should format "$jobType" as "$formatted"', () {
        expect(jobType.formattedJobType, formatted);
      });
    }
  });

  group('JobOpeningExtension', () {
    final now = DateTime(2026, 10, 21, 9);

    for (final (posted, days) in [
      (DateTime(2026, 10, 21, 1), 0),
      (DateTime(2026, 10, 20, 23, 59), 1),
      (DateTime(2026, 10, 18, 12), 3),
      (DateTime(2026, 9, 21, 12), 30),
      (DateTime(2026, 10, 22, 8), 0),
    ]) {
      test('should count $days calendar days when posted at $posted', () {
        expect(
          jobOpeningEntityFixture(publishedAt: posted).daysSincePosted(now),
          days,
        );
      });
    }

    test('should treat an opening as new for 3 days', () {
      expect(
        jobOpeningEntityFixture(publishedAt: DateTime(2026, 10, 18)).isNew(now),
        isTrue,
      );
      expect(
        jobOpeningEntityFixture(publishedAt: DateTime(2026, 10, 17)).isNew(now),
        isFalse,
      );
    });
  });

  group('engagement', () {
    for (final (title, jobTypes, engagement) in [
      ('Senior Android Engineer', ['full_time'], null),
      (
        'Senior Android Engineer (Contract)',
        <String>[],
        JobOpeningEngagement.contract,
      ),
      ('Android Engineer', ['Contractor'], JobOpeningEngagement.contract),
      ('Flutter Developer', ['freelance'], JobOpeningEngagement.freelance),
      (
        'Mobile Engineer (Freelancer)',
        <String>[],
        JobOpeningEngagement.freelance,
      ),
      ('Smart Contract Engineer', ['full_time'], null),
    ]) {
      test('should read "$title" with $jobTypes as $engagement', () {
        final jobOpening = jobOpeningEntityFixture(
          title: title,
          jobTypes: jobTypes,
        );

        expect(jobOpening.engagement, engagement);
      });
    }
  });

  group('platforms', () {
    for (final (title, tags, matchedSkills, platforms) in [
      (
        'Senior Flutter Developer',
        <String>[],
        <String>[],
        [JobOpeningPlatform.flutter],
      ),
      (
        'Mobile Engineer (Android & iOS)',
        ['flutter'],
        <String>[],
        [
          JobOpeningPlatform.flutter,
          JobOpeningPlatform.android,
          JobOpeningPlatform.ios,
        ],
      ),
      (
        'Senior Android Engineer',
        <String>[],
        ['Kotlin'],
        [JobOpeningPlatform.android],
      ),
      (
        'Mobile Engineer',
        <String>[],
        ['Jetpack Compose'],
        [JobOpeningPlatform.android],
      ),
      ('iOS Engineer', <String>[], <String>[], [JobOpeningPlatform.ios]),
      ('Mobile Engineer', <String>[], ['SwiftUI'], [JobOpeningPlatform.ios]),
      ('Backend Engineer', ['go'], ['Kotlin'], <JobOpeningPlatform>[]),
    ]) {
      test(
        'should read $platforms when "$title" has $tags and $matchedSkills',
        () {
          final jobOpening = jobOpeningEntityFixture(
            title: title,
            tags: tags,
            matchedSkills: matchedSkills,
          );

          expect(jobOpening.platforms, platforms);
        },
      );
    }
  });
}
