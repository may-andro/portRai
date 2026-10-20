import 'package:portrai/src/feature/auth/presentation/screen/sign_in/sign_in_screen.dart';
import 'package:portrai/src/route/route.dart';

class AuthModuleRoute extends ModuleRoute {
  AuthModuleRoute._({
    required super.name,
    required super.path,
    required super.builder,
  });

  static final AuthModuleRoute signIn = AuthModuleRoute._(
    name: 'sign_in',
    path: '/sign-in',
    builder: (_, _, _) => const SignInScreen(),
  );

  /// Query parameter holding the in-app location to open after signing in.
  static const redirectQueryParameter = 'redirect';

  /// The sign-in location that returns to [redirectUri] once signed in.
  static String signInLocation({required Uri redirectUri}) => Uri(
    path: signIn.path,
    queryParameters: {redirectQueryParameter: redirectUri.toString()},
  ).toString();

  /// The location to open after signing in. Only in-app paths are followed,
  /// so a crafted link cannot send the user to another site.
  static String redirectLocation(String? requestedLocation) {
    const fallbackLocation = '/';
    if (requestedLocation == null) return fallbackLocation;
    final requestedUri = Uri.tryParse(requestedLocation);
    final isInAppPath =
        requestedUri != null &&
        !requestedUri.hasScheme &&
        !requestedUri.hasAuthority &&
        requestedUri.path.startsWith('/') &&
        requestedUri.path != signIn.path;
    return isInAppPath ? requestedLocation : fallbackLocation;
  }
}
