import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/job_opening/presentation/widget/_widget.dart';

void main() {
  group('JobFitTier', () {
    for (final (score, tier) in [
      (100, JobFitTier.strong),
      (80, JobFitTier.strong),
      (79, JobFitTier.good),
      (70, JobFitTier.good),
      (69, JobFitTier.possible),
      (0, JobFitTier.possible),
    ]) {
      test('should place a score of $score in the ${tier.name} tier', () {
        expect(JobFitTier.of(score), tier);
      });
    }
  });
}
