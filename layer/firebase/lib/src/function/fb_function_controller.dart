import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase/src/auth/fb_auth_controller.dart';
import 'package:firebase/src/function/function_exception.dart';

class FbFunctionController {
  FbFunctionController(this._firebaseFunctions, this._authController);

  final FirebaseFunctions _firebaseFunctions;
  final FbAuthController _authController;

  /// Calls the HTTPS callable function [name] with [parameters] and returns
  /// the data it responds with.
  ///
  /// With [requiresSignIn] off, anyone may call it, so the function itself
  /// must check the caller, for example by enforcing App Check. With
  /// [limitedUseAppCheckToken] on, the call carries a fresh single-use App
  /// Check token, which a function that consumes its token can reject when
  /// replayed. Each such call costs one attestation.
  Future<dynamic> callFunction(
    String name, {
    Map<String, dynamic>? parameters,
    bool requiresSignIn = true,
    bool limitedUseAppCheckToken = false,
  }) async {
    try {
      // Input validation
      if (name.trim().isEmpty) {
        throw ArgumentError('Function name cannot be empty');
      }

      // Check authentication
      if (requiresSignIn && !_authController.isSignedIn) {
        throw FunctionAuthenticationException(
          Exception('User not signed in'),
          StackTrace.current,
        );
      }

      // Validate parameters
      final validatedParameters = parameters ?? <String, dynamic>{};

      // Call the function
      final callable = _firebaseFunctions.httpsCallable(
        name,
        options: HttpsCallableOptions(
          limitedUseAppCheckToken: limitedUseAppCheckToken,
        ),
      );
      final response = await callable.call<dynamic>(validatedParameters);

      // Validate response
      if (response.data == null) {
        throw FunctionEmptyResponseException(
          name,
          Exception('Function returned null data'),
          StackTrace.current,
        );
      }

      return response.data;
    } on FunctionException {
      // Re-throw our custom exceptions
      rethrow;
    } catch (error, stackTrace) {
      // Handle all other exceptions
      throw handleFunctionException(error, stackTrace, name);
    }
  }
}
