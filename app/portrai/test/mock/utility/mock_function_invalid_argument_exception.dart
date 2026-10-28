import 'package:firebase/firebase.dart';
import 'package:mocktail/mocktail.dart';

/// A refused function call, as the layer reports a `failed-precondition`
/// error.
class MockFunctionInvalidArgumentException extends Mock
    implements FunctionInvalidArgumentException {}

extension MockFunctionInvalidArgumentExceptionStub
    on MockFunctionInvalidArgumentException {
  void stubDetails(Object? details) {
    when(() => this.details).thenReturn(details);
  }
}
