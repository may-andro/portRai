import 'package:portrai/src/feature/job_opening/presentation/screen/_screen.dart';
import 'package:portrai/src/route/route.dart';

/// Both routes show private data, so both require a signed-in user.
class JobOpeningModuleRoute extends ModuleRoute {
  JobOpeningModuleRoute._({
    required super.name,
    required super.path,
    required super.builder,
  }) : super(requiresAuth: true);

  static final JobOpeningModuleRoute jobOpenings = JobOpeningModuleRoute._(
    name: 'job_openings',
    path: '/job-openings',
    builder: (_, _, _) => const JobOpeningsScreen(),
  );

  static final JobOpeningModuleRoute jobOpening = JobOpeningModuleRoute._(
    name: 'job_opening',
    path: '/job-openings/:${JobOpeningScreen.routePathParameter}',
    builder: (_, _, pathParameters) => JobOpeningScreen(
      id: pathParameters[JobOpeningScreen.routePathParameter] ?? '',
    ),
  );
}
