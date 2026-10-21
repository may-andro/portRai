import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseRemoteConfig extends Mock implements FirebaseRemoteConfig {}

extension MockFirebaseRemoteConfigStub on MockFirebaseRemoteConfig {
  void stubSetUp({required RemoteConfigFetchStatus lastFetchStatus}) {
    when(() => setConfigSettings(any())).thenAnswer((_) async {});
    when(() => setDefaults(any())).thenAnswer((_) async {});
    when(() => this.lastFetchStatus).thenReturn(lastFetchStatus);
    when(fetchAndActivate).thenAnswer((_) async => true);
    when(activate).thenAnswer((_) async => true);
  }

  void stubFetch(Future<void> Function() answer) {
    when(fetch).thenAnswer((_) => answer());
  }
}
