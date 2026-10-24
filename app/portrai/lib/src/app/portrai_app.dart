import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/connectivity/connectivity.dart';
import 'package:portrai/src/feature/force_update/force_update.dart';
import 'package:portrai/src/feature/locale/locale.dart';
import 'package:portrai/src/feature/notification/notification.dart';
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:portrai/src/route/route.dart';
import 'package:portrai/src/widget/screen_content_widget.dart';

class PortraiApp extends StatefulWidget {
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
  State<PortraiApp> createState() => _PortraiAppState();
}

class _PortraiAppState extends State<PortraiApp> {
  late GoRouter _router = widget.routeConfigurator.createRouter();

  @override
  void didUpdateWidget(PortraiApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A new router restarts navigation, so screens load their content again
    // in the new locale. Other rebuilds keep the current router.
    if (widget.appLocale != oldWidget.appLocale ||
        widget.routeConfigurator != oldWidget.routeConfigurator) {
      final previousRouter = _router;
      _router = widget.routeConfigurator.createRouter();
      // The previous router stays in use until the new one replaces it.
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => previousRouter.dispose(),
      );
    }
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PortRai',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: widget.appLocale.locale,
      debugShowCheckedModeBanner:
          widget.buildConfig.buildEnvironment.debugShowCheckedModeBanner,
      builder: (context, child) {
        return DSThemeBuilderWidget(
          brightness: context.platformBrightness,
          designSystem: widget.designSystem,
          // The router can resolve its first page a frame late, so the
          // surface fills that frame instead of black.
          child: Builder(
            builder: (context) => ColoredBox(
              color: context.colorPalette.surface.surface.color,
              child: SystemLocaleObserverWidget(
                child: ForceUpdateListenerWidget(
                  child: ConnectivityListenerWidget(
                    child: NotificationListenerWidget(
                      child: ScreenFooterProviderWidget(
                        footer: const FooterWidget(),
                        child: child ?? const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      routerConfig: _router,
    );
  }
}
