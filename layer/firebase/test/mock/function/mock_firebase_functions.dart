import 'package:cloud_functions/cloud_functions.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseFunctions extends Mock implements FirebaseFunctions {}

extension MockFirebaseFunctionsStub on MockFirebaseFunctions {
  /// Answers every [FirebaseFunctions.httpsCallable] lookup with [callable].
  void stubHttpsCallable(HttpsCallable callable) {
    when(
      () => httpsCallable(any(), options: any(named: 'options')),
    ).thenReturn(callable);
  }

  /// The options of the only [FirebaseFunctions.httpsCallable] lookup.
  HttpsCallableOptions capturedOptions() =>
      verify(
            () => httpsCallable(any(), options: captureAny(named: 'options')),
          ).captured.single
          as HttpsCallableOptions;
}
