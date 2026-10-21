import 'package:portrai/src/feature/feature_flag/feature_flag.dart';

/// Feature flags owned by the `job_opening` feature.
abstract final class JobOpeningFeatureFlags {
  static const jobOpenings = AppFeatureFlagDefinition(
    key: 'feature_job_openings',
    defaultValue: false,
    displayName: 'Job Openings',
    description:
        'Shows the Job openings card in Settings, which opens the '
        "signed-in owner's matched job openings",
  );

  static const all = [jobOpenings];
}
