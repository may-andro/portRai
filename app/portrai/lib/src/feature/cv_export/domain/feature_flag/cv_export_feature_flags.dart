import 'package:portrai/src/feature/feature_flag/feature_flag.dart';

/// Feature flags owned by the `cv_export` feature.
abstract final class CvExportFeatureFlags {
  static const tailoredCv = AppFeatureFlagDefinition(
    key: 'feature_tailored_cv',
    defaultValue: false,
    displayName: 'Tailored CV',
    description:
        'Lets a CV be tailored for a job: a rewritten summary with the most '
        'relevant projects and skills first',
  );

  static const all = [tailoredCv];
}
