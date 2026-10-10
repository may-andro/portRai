import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:portrai/src/feature/connectivity/connectivity.dart';
import 'package:portrai/src/feature/force_update/force_update.dart';
import 'package:portrai/src/feature/locale/locale.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:portrai/src/route/route.dart';

class PortraiApp extends StatelessWidget {
  const PortraiApp({
    required this.buildConfig,
    required this.designSystem,
    required this.routeConfigurator,
    required this.appLocale,
    super.key,
  });

  final AppLocale appLocale;
  final BuildConfig buildConfig;
  final DesignSystem designSystem;
  final GoRouterConfigurator routeConfigurator;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: appServiceLocator.get<AssistantBloc>(),
      child: MaterialApp.router(
        title: 'PortRai',
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: appLocale.locale,
        debugShowCheckedModeBanner:
            buildConfig.buildEnvironment.debugShowCheckedModeBanner,
        builder: (context, child) {
          return DSThemeBuilderWidget(
            brightness: context.platformBrightness,
            designSystem: designSystem,
            child: SystemLocaleObserverWidget(
              child: ForceUpdateListenerWidget(
                child: ConnectivityListenerWidget(
                  child: child ?? const SizedBox.shrink(),
                ),
              ),
            ),
          );
        },
        routerConfig: routeConfigurator.router,
      ),
    );
  }
}
