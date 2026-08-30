import 'package:cache/cache.dart';
import 'package:core/core.dart';
import 'package:error_reporter/error_reporter.dart';
import 'package:feature_flag/feature_flag.dart' as layer_ff;
import 'package:firebase/firebase.dart';
import 'package:log_reporter/log_reporter.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/firebase_options.dart';
import 'package:portrai/src/feature/app_config/app_config_module_configurator.dart';
import 'package:portrai/src/feature/developer_mode/developer_mode_module_configurator.dart';
import 'package:portrai/src/feature/experience/experience.dart';
import 'package:portrai/src/feature/expertise/expertise.dart';
import 'package:portrai/src/feature/external_app_handler/external_app_handler.dart';
import 'package:portrai/src/feature/feature_flag/feature_flag.dart';
import 'package:portrai/src/feature/force_update/force_update_module_configurator.dart';
import 'package:portrai/src/feature/locale/locale.dart';
import 'package:portrai/src/feature/portfolio/portfolio.dart';
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:portrai/src/feature/project/project.dart';
import 'package:portrai/src/feature/service/service.dart';
import 'package:portrai/src/feature/setting/setting.dart';
import 'package:portrai/src/feature/testimonial/testimonial.dart';
import 'package:portrai/src/module_configurator/app_module_configurator.dart';
import 'package:portrai/src/route/route_module_configurator.dart';
import 'package:portrai/src/utility/utility_module_configurator.dart';
import 'package:remote/remote.dart';
import 'package:tracking/tracking.dart';
import 'package:use_case/use_case.dart';

List<ModuleConfigurator> getModuleConfigurators(BuildConfig buildConfig) => [
  AppModuleConfigurator(buildConfig),
  FirebaseModuleConfigurator(
    isFirebaseEnabled: buildConfig.buildEnvironment.isFirebaseEnabled,
    firebaseOptions: DefaultFirebaseOptions.currentPlatform,
    appCheckToken: '',
    storageBucketUrl: '',
  ),
  TrackingModuleConfigurator(buildConfig.buildEnvironment.isFirebaseEnabled),
  LogReporterModuleConfigurator(),
  AppConfigModuleConfigurator(),
  RouteModuleConfigurator(),
  UtilityModuleConfigurator(),
  UseCaseModuleConfigurator(),
  ErrorReporterModuleConfigurator(
    buildConfig.buildEnvironment.isFirebaseEnabled,
  ),
  const CacheModuleConfigurator(),
  RemoteModuleConfigurator(
    buildConfig.buildEnvironment.isRemoteLoggingEnabled,
    '',
  ),
  layer_ff.FeatureFlagModuleConfigurator(appId: 'portrai'),
  AppFeatureFlagModuleConfigurator(),
  ExternalAppHandlerModuleConfigurator(),
  ForceUpdateModuleConfigurator(),
  LocaleModuleConfigurator(),
  SettingModuleConfigurator(),
  DeveloperModeModuleConfigurator(),
  ExperienceModuleConfigurator(),
  ServiceModuleConfigurator(),
  ProjectModuleConfigurator(),
  TestimonialModuleConfigurator(),
  ProfileModuleConfigurator(),
  ExpertiseModuleConfigurator(),
  PortfolioModuleConfigurator(),
];
