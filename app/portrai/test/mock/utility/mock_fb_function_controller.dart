import 'package:firebase/firebase.dart';
import 'package:mocktail/mocktail.dart';

class MockFbFunctionController extends Mock implements FbFunctionController {}

extension MockFbFunctionControllerStub on MockFbFunctionController {
  /// Stubs every call of the function [name] to return [responseData].
  void stubCallFunction(String name, Object? responseData) {
    when(
      () => callFunction(
        name,
        parameters: any(named: 'parameters'),
        requiresSignIn: any(named: 'requiresSignIn'),
        limitedUseAppCheckToken: any(named: 'limitedUseAppCheckToken'),
      ),
    ).thenAnswer((_) async => responseData);
  }

  /// Stubs every call of the function [name] to throw [error].
  void stubCallFunctionThrows(String name, Object error) {
    when(
      () => callFunction(
        name,
        parameters: any(named: 'parameters'),
        requiresSignIn: any(named: 'requiresSignIn'),
        limitedUseAppCheckToken: any(named: 'limitedUseAppCheckToken'),
      ),
    ).thenThrow(error);
  }
}
