import 'package:flutter/material.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/route/observer/focus_clearing_route_observer.dart';

import 'package:portrai/src/route/route_module_configurator.di.g.dart';

@generateConfigurator
class RouteModuleConfigurator extends SimpleModuleConfigurator {
  @override
  void registerDependencies(ServiceLocator sl) {
    // Auto-generated registrations
    $registerRouteDependencies(sl);

    // Manual: FocusClearingRouteObserver takes FocusManager.instance (not in DI)
    sl.factory(() => FocusClearingRouteObserver(FocusManager.instance));
  }
}
