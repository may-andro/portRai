import 'dart:async';

import 'package:core/core.dart';
import 'package:feature_flag/src/data/data.dart';
import 'package:feature_flag/src/feature_flag_controller.dart';
import 'package:firebase/firebase.dart';
import 'package:module_injector/module_injector.dart';

/// [appId] namespaces this app's cached flag overrides so this package can
/// be embedded in multiple apps (e.g. `portrai`, `storybook`) without their
/// caches colliding, even for identical flag keys.
///
/// Unlike most other module configurators, this one does **not** call
/// [FeatureFlagController.initFeatureFlags] automatically: the flag catalog
/// (the `List<FeatureFlagDefinition>`) is only known by the host app's own
/// features, so the host app's composition root must call it explicitly -
/// typically after every other module has finished registering its
/// definitions.
class FeatureFlagModuleConfigurator implements ModuleConfigurator {
  FeatureFlagModuleConfigurator({required this.appId});

  final String appId;

  @override
  FutureOr<void> preDependenciesSetup(ServiceLocator serviceLocator) {}

  @override
  FutureOr<void> postDependenciesSetup(ServiceLocator serviceLocator) {}

  @override
  FutureOr<void> registerDependencies(ServiceLocator serviceLocator) {
    // cache
    serviceLocator.registerSingleton<FeatureFlagCache>(
      () => FeatureFlagCache(appId: appId),
    );

    // data source
    final remoteDataSource = RemoteFeatureFlagDataSource(
      serviceLocator.get<FbRemoteConfigController>(),
    );
    final cachedDataSource = CacheFeatureFlagDataSource(
      remoteDataSource,
      serviceLocator.get<FeatureFlagCache>(),
    );
    serviceLocator.registerSingleton<FeatureFlagDataSource>(
      () => BuildEnvFeatureFlagDataSource(
        serviceLocator.get<BuildConfig>(),
        cachedDataSource,
        remoteDataSource,
      ),
    );

    // controller
    serviceLocator.registerSingleton<FeatureFlagController>(
      () => FeatureFlagController(serviceLocator.get<FeatureFlagDataSource>()),
    );
  }
}
