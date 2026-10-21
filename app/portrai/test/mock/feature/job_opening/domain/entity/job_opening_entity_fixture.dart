import 'package:portrai/src/feature/job_opening/domain/_domain.dart';

/// A complete job opening for tests; override only what a test is about.
JobOpeningEntity jobOpeningEntityFixture({
  String id = 'job-1',
  String title = 'Senior Flutter Developer',
  int score = 82,
  String? location = 'Europe',
  List<String> matchedSkills = const ['Flutter', 'Dart'],
  List<String> missingSkills = const ['GraphQL'],
  List<String> reasons = const ['The core stack is Flutter.'],
  DateTime? publishedAt,
}) => JobOpeningEntity(
  id: id,
  sourceName: 'Remotive',
  title: title,
  company: 'Acme',
  url: Uri.parse('https://remotive.com/remote-jobs/software-development/1'),
  location: location,
  tags: const ['flutter'],
  jobTypes: const ['full_time'],
  description: 'Build mobile apps with Flutter.',
  score: score,
  matchedSkills: matchedSkills,
  missingSkills: missingSkills,
  reasons: reasons,
  publishedAt: publishedAt ?? DateTime.utc(2026, 10, 17),
  fetchedAt: DateTime.utc(2026, 10, 19, 4),
);
