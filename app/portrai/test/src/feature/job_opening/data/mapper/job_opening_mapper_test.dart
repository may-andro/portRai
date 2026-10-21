import 'package:firebase/firebase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/job_opening/data/_data.dart';

void main() {
  group('JobOpeningMapper', () {
    Map<String, dynamic> document({Object score = 82}) => {
      'id': 'job-1',
      'source': 'remotive',
      'sourceName': 'Remotive',
      'title': 'Senior Flutter Developer',
      'company': 'Acme',
      'url': 'https://remotive.com/remote-jobs/1',
      'location': null,
      'description': 'Build apps.',
      'score': score,
      'matchedSkills': ['Flutter'],
      'missingSkills': ['GraphQL'],
      'reasons': ['Flutter role.'],
      'publishedAt': Timestamp.fromDate(DateTime.utc(2026, 10, 17)),
      'fetchedAt': Timestamp.fromDate(DateTime.utc(2026, 10, 19)),
      'expiresAt': Timestamp.fromDate(DateTime.utc(2026, 11, 2)),
    };

    test('should map every field when the document is complete', () {
      final jobOpening = const JobOpeningMapper().map(
        JobOpeningModel.fromJson(document()),
      );

      expect(jobOpening.id, 'job-1');
      expect(jobOpening.sourceName, 'Remotive');
      expect(jobOpening.url, Uri.parse('https://remotive.com/remote-jobs/1'));
      expect(jobOpening.location, isNull);
      expect(jobOpening.tags, isEmpty);
      expect(jobOpening.score, 82);
      expect(jobOpening.matchedSkills, ['Flutter']);
      expect(jobOpening.missingSkills, ['GraphQL']);
      expect(jobOpening.reasons, ['Flutter role.']);
      expect(jobOpening.publishedAt.toUtc(), DateTime.utc(2026, 10, 17));
    });

    test('should round and clamp the score when it is out of range', () {
      const mapper = JobOpeningMapper();

      expect(
        mapper.map(JobOpeningModel.fromJson(document(score: 71.6))).score,
        72,
      );
      expect(
        mapper.map(JobOpeningModel.fromJson(document(score: 140))).score,
        100,
      );
    });
  });
}
