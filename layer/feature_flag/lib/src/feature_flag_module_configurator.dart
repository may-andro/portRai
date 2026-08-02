import 'dart:async';

import 'package:core/core.dart';
import 'package:feature_flag/src/data/data.dart';
import 'package:feature_flag/src/feature_flag_controller.dart';
import 'package:firebase/firebase.dart';
import 'package:module_injector/module_injector.dart';

class FeatureFlagModuleConfigurator implements ModuleConfigurator {
  @override
  FutureOr<void> preDependenciesSetup(ServiceLocator serviceLocator) {}

  @override
  FutureOr<void> postDependenciesSetup(ServiceLocator serviceLocator) async {
    await serviceLocator.get<FeatureFlagController>().initFeatureFlags();
  }

  @override
  FutureOr<void> registerDependencies(ServiceLocator serviceLocator) {
    // cache
    serviceLocator.registerSingleton<FeatureFlagCache>(
      () => FeatureFlagCache(),
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
