import 'package:flutter/material.dart';
import 'package:log_reporter/log_reporter.dart';
import 'package:module_injector/module_injector.dart';

@register
class RouteNavigationObserver extends NavigatorObserver {
  RouteNavigationObserver(this.logReporter);

  final LogReporter logReporter;

  static const _tag = 'RouteNavigationObserver';

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    logReporter.debug(
      'New route pushed: ${route.settings.name}, previous route was: ${previousRoute?.settings.name}',
      tag: _tag,
    );
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    logReporter.debug(
      'Route popped: ${route.settings.name}, previous route was: ${previousRoute?.settings.name}',
      tag: _tag,
    );
  }
}
