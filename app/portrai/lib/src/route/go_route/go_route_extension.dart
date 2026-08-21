import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:portrai/src/route/core/module_route.dart';

extension GoRouteExtension on BuildContext {
  void popScreenUntil(ModuleRouteInfo route) {
    while ((canPop()) && (ModalRoute.of(this)!.settings.name != route.name)) {
      pop();
    }
  }

  void popScreen() => pop();

  void pushScreen(
    ModuleRouteInfo route, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
    Object? extra,
  }) {
    pushNamed(
      route.name,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      extra: extra,
    );
  }
}

extension GoRouterStateExtension on GoRouterState {
  CustomTransitionPage<dynamic> getCustomTransitionPage(Widget child) {
    return CustomTransitionPage(
      key: pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final opacity = CurveTween(
          curve: Curves.easeInOutCirc,
        ).animate(animation);
        return FadeTransition(opacity: opacity, child: child);
      },
    );
  }
}
