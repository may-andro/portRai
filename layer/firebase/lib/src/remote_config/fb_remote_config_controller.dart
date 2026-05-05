import 'package:firebase_remote_config/firebase_remote_config.dart';

class FbRemoteConfigController {
  FbRemoteConfigController(this._firebaseRemoteConfig);

  final FirebaseRemoteConfig _firebaseRemoteConfig;

  Future<void> initialiseRemoteConfig({
    required Map<String, dynamic> defaultConfigsMap,
  }) async {
    await _firebaseRemoteConfig.setDefaults(defaultConfigsMap);
    await _firebaseRemoteConfig.fetchAndActivate();
  }

  RemoteConfigValue getValueForKey(String input) {
    return _firebaseRemoteConfig.getValue(input);
  }

  Map<String, RemoteConfigValue> getAllConfigsValue() {
    return _firebaseRemoteConfig.getAll();
  }
}
