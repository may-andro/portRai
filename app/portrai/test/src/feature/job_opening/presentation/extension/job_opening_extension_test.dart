import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/job_opening/presentation/extension/_extension.dart';

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
}
