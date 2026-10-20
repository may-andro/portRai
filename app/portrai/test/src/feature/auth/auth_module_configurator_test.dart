import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/auth/auth.dart';
import 'package:portrai/src/route/route.dart';
import 'package:use_case/use_case.dart';

import '../../../mock/feature/auth/domain/use_case/mock_get_signed_in_user_use_case.dart';
import '../../../mock/utility/mock_module_route_controller.dart';
import '../../../mock/utility/mock_service_locator.dart';

void main() {
  setUpAll(() => registerFallbackValue(_noRedirect));

  group('AuthModuleConfigurator', () {
    late MockServiceLocator serviceLocator;
    late MockModuleRouteController routeController;
    late MockGetSignedInUserUseCase getSignedInUserUseCase;
    late ModuleRouteRedirect authRedirect;

    final requestedUri = Uri.parse('/job-openings');

    setUp(() async {
      serviceLocator = MockServiceLocator();
      routeController = MockModuleRouteController();
      getSignedInUserUseCase = MockGetSignedInUserUseCase();

      when(
        () => serviceLocator.get<ModuleRouteController>(),
      ).thenReturn(routeController);
      when(
        () => serviceLocator.get<GetSignedInUserUseCase>(),
      ).thenReturn(getSignedInUserUseCase);
      when(
        () => routeController.register(AuthModuleRoute.signIn),
      ).thenReturn(null);
      when(() => routeController.registerAuthRedirect(any())).thenReturn(null);

      await AuthModuleConfigurator().postDependenciesSetup(serviceLocator);
      authRedirect =
          verify(
                () => routeController.registerAuthRedirect(captureAny()),
              ).captured.single
              as ModuleRouteRedirect;
    });

    test('should register the sign-in route', () {
      verify(() => routeController.register(AuthModuleRoute.signIn)).called(1);
    });

    test('should keep the requested route when a user is signed in', () async {
      getSignedInUserUseCase.stubCall(
        const Right(
          AuthUserEntity(id: 'owner-uid', email: 'owner@example.com'),
        ),
      );

      final redirectPath = await authRedirect(
        _FakeBuildContext(),
        requestedUri,
      );

      expect(redirectPath, isNull);
    });

    test('should redirect to sign in when nobody is signed in', () async {
      getSignedInUserUseCase.stubCall(const Right(null));

      final redirectPath = await authRedirect(
        _FakeBuildContext(),
        requestedUri,
      );

      expect(
        redirectPath,
        AuthModuleRoute.signInLocation(redirectUri: requestedUri),
      );
    });

    test('should redirect to sign in when the check fails', () async {
      getSignedInUserUseCase.stubCall(
        const Left(GetSignedInUserUnknownFailure()),
      );

      final redirectPath = await authRedirect(
        _FakeBuildContext(),
        requestedUri,
      );

      expect(
        redirectPath,
        AuthModuleRoute.signInLocation(redirectUri: requestedUri),
      );
    });
  });
}

class _FakeBuildContext extends Fake implements BuildContext {}

FutureOr<String?> _noRedirect(BuildContext context, Uri requestedUri) => null;
