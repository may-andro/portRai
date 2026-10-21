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

  /// Replaces the navigation stack with [route].
  void goScreen(ModuleRouteInfo route) => goNamed(route.name);

  /// Replaces the navigation stack with the in-app [location], e.g. a path
  /// carried in a query parameter.
  void goLocation(String location) => go(location);

  /// Replaces the current page with the in-app [location] without adding a
  /// browser history entry, so Back skips the page being left, such as a
  /// sign-in page once signed in.
  void replaceLocation(String location) =>
      Router.neglect(this, () => pushReplacement(location));

  /// Query parameters of the route that built this context.
  Map<String, String> get routeQueryParameters =>
      GoRouterState.of(this).uri.queryParameters;

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
