import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:firebase/firebase.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:log_reporter/log_reporter.dart';
import 'package:portrai/src/app/portrai_app.dart';
import 'package:portrai/src/app/splash_app.dart';
import 'package:portrai/src/feature/locale/locale.dart';
import 'package:portrai/src/module_configurator/module_configurators.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:portrai/src/route/route.dart';
import 'package:portrai/src/utility/app_bloc_observer.dart';
import 'package:tracking/tracking.dart';

Future<void> runAppWithInitialization() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle());

  final buildConfig = BuildConfig(
    buildEnvironment: BuildEnvironment.buildEnvironment,
  );
  final moduleConfigurators = getModuleConfigurators(buildConfig);

  FlutterNativeSplash.remove();

  runApp(
    SplashApp(
      buildConfig: buildConfig,
      moduleConfigurators: moduleConfigurators,
      onInitializationSuccessful: runMainApp,
    ),
  );
}

void runMainApp(DesignSystem designSystem) {
  final appLocale = appServiceLocator.get<AppLocale>();
  _sendAppInitializationFinishedEvent(appLocale);
  Bloc.observer = appServiceLocator.get<AppBlocObserver>();

  runApp(
    LocaleListenerWidget(
      builder: (context, appLocale) {
        return PortraiApp(
          appLocale: appLocale,
          buildConfig: appServiceLocator.get<BuildConfig>(),
          designSystem: designSystem,
          routeConfigurator: _routeConfigurator,
        );
      },
    ),
  );
}

GoRouterConfigurator get _routeConfigurator {
  final moduleRouteController = appServiceLocator.get<ModuleRouteController>();
  final navigationObservers = [
    appServiceLocator.get<FirebaseAnalyticsObserver>(),
    appServiceLocator.get<RouteNavigationObserver>(),
    appServiceLocator.get<FocusClearingRouteObserver>(),
    routeObserver,
  ];
  final routeConfigurator = GoRouterConfigurator(
    moduleRouteController,
    navigationObservers,
  );
  return routeConfigurator;
}

void _sendAppInitializationFinishedEvent(AppLocale appLocale) {
  final logReporter = appServiceLocator.get<LogReporter>();
  logReporter.debug(
    'Project is setup in locale: ${appLocale.locale}',
    tag: 'runAppWithInitialization',
  );

  final trackingReporter = appServiceLocator.get<TrackingReporter>();
  trackingReporter.sendTrackingEvent(AppInitializationFinishedTracking());
}
