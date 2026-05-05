import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase/src/auth/fb_auth_controller.dart';
import 'package:firebase/src/function/function_exception.dart';

class FbFunctionController {
  FbFunctionController(this._firebaseFunctions, this._authController);

  final FirebaseFunctions _firebaseFunctions;
  final FbAuthController _authController;

  Future<dynamic> callFunction(
    String name, {
    Map<String, dynamic>? parameters,
  }) async {
    try {
      // Input validation
      if (name.trim().isEmpty) {
        throw ArgumentError('Function name cannot be empty');
      }

      // Check authentication
      final user = _authController.currentUser;
      if (user == null) {
        throw FunctionAuthenticationException(
          Exception('User not signed in'),
          StackTrace.current,
        );
      }

      // Validate parameters
      final validatedParameters = parameters ?? <String, dynamic>{};

      // Call the function
      final callable = _firebaseFunctions.httpsCallable(name);
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
