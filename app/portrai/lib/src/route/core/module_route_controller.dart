import 'package:core/core.dart';
import 'package:log_reporter/log_reporter.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/route/core/module_route.dart';

@registerSingleton
class ModuleRouteController {
  ModuleRouteController(this._logReporter);

  final LogReporter _logReporter;

  final List<ModuleRoute> _routes = [];

  void register(ModuleRoute moduleRoute) {
    if (_routes.contains(moduleRoute)) {
      _logReporter.error(
        'Duplicate ModuleRoute found ${moduleRoute.runtimeType}',
        stacktrace: StackTrace.current,
        error: _ModuleRouteRegisteredException(),
        tag: 'ModuleRouteController',
      );
    }
    _routes.add(moduleRoute);
  }

  /// Returns all routes from all modules (including nested).
  List<ModuleRoute> get allRoutes => _routes;
}

class _ModuleRouteRegisteredException implements AppException {
  @override
  String toString() {
    return '_ModuleRouteRegisteredException: The ModuleRoute is already registered';
  }
}
