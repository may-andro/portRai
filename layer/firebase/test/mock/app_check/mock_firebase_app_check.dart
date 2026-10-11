import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAppCheck extends Mock implements FirebaseAppCheck {}

extension MockFirebaseAppCheckStub on MockFirebaseAppCheck {
  void stubActivate({Object? error, StackTrace? stackTrace}) {
    when(
      () => activate(
        providerWeb: any(named: 'providerWeb'),
        providerAndroid: any(named: 'providerAndroid'),
        providerApple: any(named: 'providerApple'),
      ),
    ).thenAnswer((_) async {
      if (error != null) {
        Error.throwWithStackTrace(error, stackTrace ?? StackTrace.current);
      }
    });
  }

  void stubTokenAutoRefresh({Object? error}) {
    when(() => setTokenAutoRefreshEnabled(true)).thenAnswer((_) async {
      if (error != null) {
        throw error;
      }
    });
  }
}
