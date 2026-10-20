import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:log_reporter/log_reporter.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/route/core/module_route.dart';

/// Returns the path to redirect to, or null to keep the [requestedUri].
typedef ModuleRouteRedirect =
    FutureOr<String?> Function(BuildContext context, Uri requestedUri);

@registerSingleton
class ModuleRouteController {
  ModuleRouteController(this._logReporter);

  final LogReporter _logReporter;

  final List<ModuleRoute> _routes = [];
  final List<ModuleRouteRedirect> _redirects = [];
  ModuleRouteRedirect? _authRedirect;

  void register(ModuleRoute moduleRoute) {
    if (_routes.contains(moduleRoute)) {
      _logReporter.error(
        'Duplicate ModuleRoute found ${moduleRoute.runtimeType}',
        stacktrace: StackTrace.current,
        error: _ModuleRouteRegisteredException(),
        tag: 'ModuleRouteController',
      );
      return;
    }
    _routes.add(moduleRoute);
  }

  void registerRedirect(ModuleRouteRedirect redirect) {
    _redirects.add(redirect);
  }

  List<ModuleRouteRedirect> get redirects => List.unmodifiable(_redirects);

  /// Guards every route with [ModuleRoute.requiresAuth]. Only one can be
  /// registered.
  void registerAuthRedirect(ModuleRouteRedirect redirect) {
    if (_authRedirect != null) {
      _logReporter.error(
        'Auth redirect is already registered',
        stacktrace: StackTrace.current,
        error: _AuthRedirectRegisteredException(),
        tag: 'ModuleRouteController',
      );
      return;
    }
    _authRedirect = redirect;
  }

  ModuleRouteRedirect? get authRedirect => _authRedirect;

  List<ModuleRoute> get allRoutes => List.unmodifiable(_routes);
}

class _ModuleRouteRegisteredException implements AppException {
  @override
  String toString() {
    return '_ModuleRouteRegisteredException: The ModuleRoute is already registered';
  }
}

class _AuthRedirectRegisteredException implements AppException {
  @override
  String toString() {
    return '_AuthRedirectRegisteredException: The auth redirect is already registered';
  }
}
