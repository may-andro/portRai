import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:portrai/src/route/route.dart';

/// Configures the application's routing system with authentication-based redirects.
class GoRouterConfigurator {
  const GoRouterConfigurator(this._controller, this.navigationObservers);

  final ModuleRouteController _controller;
  final List<NavigatorObserver> navigationObservers;

  /// Converts a ModuleRoute to a GoRoute, handling nested routes and auth redirects.
  GoRoute _convertModuleRoute(ModuleRoute route) {
    return GoRoute(
      name: route.name,
      path: route.path,
      /*builder: (context, state) {
        return route.builder(context, state.extra, state.pathParameters);
      },*/
      pageBuilder: (context, state) {
        return state.getCustomTransitionPage(
          route.builder(context, state.extra, state.pathParameters),
        );
      },
      routes: route.children.map(_convertModuleRoute).toList(),
      redirect: route.requiresAuth
          ? (context, state) {
              // TODO(auth): Replace with your actual authentication logic
              const isAuthenticated = false; // Example placeholder
              if (!isAuthenticated) {
                return '/login'; // Update to your login route
              }
            }
          : null,
    );
  }

  /// Creates the GoRouter instance with authentication-based redirect logic.
  GoRouter get router {
    if (kIsWeb) {
      GoRouter.optionURLReflectsImperativeAPIs = true;
    }
    final allRoutes = _controller.allRoutes.map(_convertModuleRoute).toList();

    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: '/',
      routes: allRoutes,
      observers: navigationObservers,
      errorBuilder: (_, _) => const RouteNotFoundScreen(),
    );
  }
}
