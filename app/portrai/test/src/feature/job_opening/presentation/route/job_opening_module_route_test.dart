import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/job_opening/presentation/route/_route.dart';

void main() {
  test(
    'should require sign-in for both routes when they show private data',
    () {
      expect(JobOpeningModuleRoute.jobOpenings.requiresAuth, isTrue);
      expect(JobOpeningModuleRoute.jobOpening.requiresAuth, isTrue);
    },
  );

  test('should take the opening ID from the path when opening one', () {
    expect(JobOpeningModuleRoute.jobOpenings.path, '/job-openings');
    expect(JobOpeningModuleRoute.jobOpening.path, '/job-openings/:id');
  });
}
