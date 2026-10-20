import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/auth/auth_module_configurator.di.g.dart';
import 'package:portrai/src/feature/auth/domain/_domain.dart';
import 'package:portrai/src/feature/auth/presentation/route/_route.dart';
import 'package:portrai/src/route/route.dart';

@generateConfigurator
class AuthModuleConfigurator extends SimpleModuleConfigurator {
  @override
  void registerDependencies(ServiceLocator sl) => $registerAuthDependencies(sl);

  @override
  Future<void> postDependenciesSetup(ServiceLocator sl) async {
    final routeController = sl.get<ModuleRouteController>()
      ..register(AuthModuleRoute.signIn);

    final getSignedInUserUseCase = sl.get<GetSignedInUserUseCase>();
    routeController.registerAuthRedirect((context, requestedUri) async {
      final signedInUserEither = await getSignedInUserUseCase();
      final isSignedIn =
          signedInUserEither.isRight && signedInUserEither.right != null;
      return isSignedIn
          ? null
          : AuthModuleRoute.signInLocation(redirectUri: requestedUri);
    });
  }
}
