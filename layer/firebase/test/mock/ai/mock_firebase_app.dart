import 'package:firebase_core/firebase_core.dart';
import 'package:mocktail/mocktail.dart';

// Only SDK configuration is read; no platform Firebase app is initialized.
// ignore: avoid_implementing_value_types
class MockFirebaseApp extends Mock implements FirebaseApp {}

extension MockFirebaseAppStub on MockFirebaseApp {
  void stubOptions() {
    when(() => name).thenReturn('ai-unit-tests');
    when(() => options).thenReturn(
      const FirebaseOptions(
        apiKey: 'unit-test-placeholder',
        appId: 'unit-test-app',
        messagingSenderId: 'unit-test-sender',
        projectId: 'unit-test-project',
      ),
    );
    when(() => isAutomaticDataCollectionEnabled).thenReturn(false);
  }
}
