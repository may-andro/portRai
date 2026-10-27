import 'package:cloud_functions/cloud_functions.dart';
import 'package:mocktail/mocktail.dart';

class MockHttpsCallableResult extends Mock
    implements HttpsCallableResult<dynamic> {}

extension MockHttpsCallableResultStub on MockHttpsCallableResult {
  void stubData(Object? responseData) {
    when(() => data).thenReturn(responseData);
  }
}
