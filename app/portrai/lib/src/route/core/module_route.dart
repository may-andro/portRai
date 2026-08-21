import 'package:flutter/widgets.dart';

abstract class ModuleRouteInfo {
  String get name;

  String get path;
}

class ModuleRoute implements ModuleRouteInfo {
  const ModuleRoute({
    required this.name,
    required this.path,
    required this.builder,
    this.children = const [],
    this.requiresAuth = false,
  });

  @override
  final String name;
  @override
  final String path;
  final Widget Function(
    BuildContext context,
    dynamic extra,
    Map<String, String> pathParameters,
  )
  builder;
  final List<ModuleRoute> children;
  final bool requiresAuth;
}
