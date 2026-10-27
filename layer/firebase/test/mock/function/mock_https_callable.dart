import 'package:cloud_functions/cloud_functions.dart';
import 'package:mocktail/mocktail.dart';

import 'mock_https_callable_result.dart';

class MockHttpsCallable extends Mock implements HttpsCallable {}

extension MockHttpsCallableStub on MockHttpsCallable {
  /// Answers every call with [responseData], or throws [error] when given.
  void stubCall({Object? responseData, Object? error}) {
    final callableResult = MockHttpsCallableResult()..stubData(responseData);
    when(() => call<dynamic>(any<dynamic>())).thenAnswer((_) async {
      if (error != null) throw error;
      return callableResult;
    });
  }
}
