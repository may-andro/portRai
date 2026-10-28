import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase/src/function/fb_function_controller.dart';
import 'package:firebase/src/function/function_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mock/auth/mock_fb_auth_controller.dart';
import '../../mock/function/mock_firebase_functions.dart';
import '../../mock/function/mock_https_callable.dart';

void main() {
  setUpAll(() => registerFallbackValue(HttpsCallableOptions()));

  group(FbFunctionController, () {
    late MockFirebaseFunctions functions;
    late MockHttpsCallable callable;
    late MockFbAuthController authController;
    late FbFunctionController controller;

    setUp(() {
      functions = MockFirebaseFunctions();
      callable = MockHttpsCallable();
      authController = MockFbAuthController();
      controller = FbFunctionController(functions, authController);
      functions.stubHttpsCallable(callable);
    });

    test('should return the response data when a signed-in user calls a '
        'function', () async {
      authController.stubIsSignedIn(true);
      callable.stubCall(responseData: {'status': 'done'});

      final responseData = await controller.callFunction(
        'runTask',
        parameters: {'itemId': 'item-1'},
      );

      expect(responseData, {'status': 'done'});
      verify(
        () =>
            functions.httpsCallable('runTask', options: any(named: 'options')),
      ).called(1);
      verify(() => callable.call<dynamic>({'itemId': 'item-1'})).called(1);
    });

    test('should throw an authentication error without calling when no user '
        'is signed in', () async {
      authController.stubIsSignedIn(false);

      await expectLater(
        controller.callFunction('runTask'),
        throwsA(isA<FunctionAuthenticationException>()),
      );
      verifyNever(
        () => functions.httpsCallable(any(), options: any(named: 'options')),
      );
    });

    test('should call the function when sign-in is not required and no user '
        'is signed in', () async {
      authController.stubIsSignedIn(false);
      callable.stubCall(responseData: {'slots': <String>[]});

      final responseData = await controller.callFunction(
        'listItems',
        requiresSignIn: false,
      );

      expect(responseData, {'slots': <String>[]});
    });

    test('should send the cached App Check token when no limited-use token '
        'is asked for', () async {
      authController.stubIsSignedIn(true);
      callable.stubCall(responseData: true);

      await controller.callFunction('runTask');

      expect(functions.capturedOptions().limitedUseAppCheckToken, isFalse);
    });

    test('should ask for a limited-use App Check token when the call needs '
        'one', () async {
      authController.stubIsSignedIn(false);
      callable.stubCall(responseData: true);

      await controller.callFunction(
        'runTask',
        requiresSignIn: false,
        limitedUseAppCheckToken: true,
      );

      expect(functions.capturedOptions().limitedUseAppCheckToken, isTrue);
    });

    test('should throw an empty response error when the function returns no '
        'data', () async {
      authController.stubIsSignedIn(true);
      callable.stubCall();

      await expectLater(
        controller.callFunction('runTask'),
        throwsA(isA<FunctionEmptyResponseException>()),
      );
    });

    test('should keep the details the function sent with its error', () async {
      authController.stubIsSignedIn(false);
      callable.stubCall(
        error: FirebaseFunctionsException(
          code: 'failed-precondition',
          message: 'refused',
          details: const {'reason': 'not_ready'},
        ),
      );

      await expectLater(
        controller.callFunction('runTask', requiresSignIn: false),
        throwsA(
          isA<FunctionException>().having(
            (exception) => exception.details,
            'details',
            {'reason': 'not_ready'},
          ),
        ),
      );
    });

    test('should have no details when the error did not come from the '
        'function', () async {
      authController.stubIsSignedIn(true);
      callable.stubCall();

      await expectLater(
        controller.callFunction('runTask'),
        throwsA(
          isA<FunctionException>().having(
            (exception) => exception.details,
            'details',
            isNull,
          ),
        ),
      );
    });

    for (final (code, exceptionMatcher) in [
      ('unauthenticated', isA<FunctionAuthenticationException>()),
      ('permission-denied', isA<FunctionPermissionDeniedException>()),
      ('invalid-argument', isA<FunctionInvalidArgumentException>()),
      ('resource-exhausted', isA<FunctionQuotaExceededException>()),
    ]) {
      test(
        'should map the $code error when the function fails with it',
        () async {
          authController.stubIsSignedIn(false);
          callable.stubCall(
            error: FirebaseFunctionsException(code: code, message: code),
          );

          await expectLater(
            controller.callFunction('runTask', requiresSignIn: false),
            throwsA(exceptionMatcher),
          );
        },
      );
    }
  });
}
