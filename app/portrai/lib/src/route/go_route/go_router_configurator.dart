import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:portrai/src/route/route.dart';

/// Configures the application's routing system with authentication-based redirects.
class GoRouterConfigurator {
  const GoRouterConfigurator(this._controller, this.navigationObservers);

  static const _initialLocation = '/';

  final ModuleRouteController _controller;
  final List<NavigatorObserver> navigationObservers;

  /// Converts a ModuleRoute to a GoRoute, handling nested routes and auth redirects.
  GoRoute _convertModuleRoute(ModuleRoute route) {
    return GoRoute(
      name: route.name,
      path: route.path,
      builder: (context, state) {
        return route.builder(context, state.extra, state.pathParameters);
      },
      pageBuilder: kIsWeb
          ? (context, state) {
              return state.getCustomTransitionPage(
                route.builder(context, state.extra, state.pathParameters),
              );
            }
          : null,
      routes: route.children.map(_convertModuleRoute).toList(),
      redirect: route.requiresAuth
          ? (context, state) {
              final authRedirect = _controller.authRedirect;
              // Without a registered guard, fail closed to the start page.
              if (authRedirect == null) return _initialLocation;
              return authRedirect(context, state.uri);
            }
          : null,
    );
  }

  /// Creates a new GoRouter instance with authentication-based redirect logic.
  ///
  /// Each call returns a new router that starts navigation from the initial
  /// location, so callers keep the router for as long as navigation should
  /// last.
  GoRouter createRouter() {
    if (kIsWeb) {
      GoRouter.optionURLReflectsImperativeAPIs = true;
    }
    final allRoutes = _controller.allRoutes.map(_convertModuleRoute).toList();

    return GoRouter(
      navigatorKey: createRootNavigatorKey(),
      initialLocation: _initialLocation,
      routes: allRoutes,
      redirect: (context, state) async {
        for (final redirect in _controller.redirects) {
          final redirectPath = await redirect(context, state.uri);
          if (redirectPath != null) return redirectPath;
        }
        return null;
      },
      observers: navigationObservers,
      errorBuilder: (_, _) => const RouteNotFoundScreen(),
    );
  }
}
