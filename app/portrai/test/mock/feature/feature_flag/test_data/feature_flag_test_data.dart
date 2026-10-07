import 'package:portrai/src/feature/feature_flag/domain/_domain.dart';

const testimonialsDefinition = AppFeatureFlagDefinition(
  key: 'feature_testimonials_section',
  defaultValue: false,
  displayName: 'Testimonials Section',
  description: 'Enables the testimonials section on portfolio page',
);

const servicesDefinition = AppFeatureFlagDefinition(
  key: 'feature_services_section',
  defaultValue: false,
  displayName: 'Services Section',
  description: 'Enables the services section on portfolio page',
);

const testimonialsFlag = AppFeatureFlagEntity(
  flag: testimonialsDefinition,
  isEnabled: false,
  isOverridden: false,
);

const servicesFlag = AppFeatureFlagEntity(
  flag: servicesDefinition,
  isEnabled: true,
  isOverridden: true,
  hasRemoteSource: true,
  remoteValue: false,
);

const allFeatureFlags = [testimonialsFlag, servicesFlag];
