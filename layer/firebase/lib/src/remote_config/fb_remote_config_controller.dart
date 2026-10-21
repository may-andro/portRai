import 'package:firebase_remote_config/firebase_remote_config.dart';

class FbRemoteConfigController {
  FbRemoteConfigController(this._firebaseRemoteConfig);

  static const _fetchTimeout = Duration(seconds: 5);
  static const _minimumFetchInterval = Duration(hours: 12);

  final FirebaseRemoteConfig _firebaseRemoteConfig;

  /// Waits for the network only when nothing was fetched before. Otherwise it
  /// activates the values fetched earlier and refreshes them in the
  /// background, so the new values apply on the next launch.
  Future<void> initialiseRemoteConfig({
    required Map<String, dynamic> defaultConfigsMap,
  }) async {
    await _firebaseRemoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: _fetchTimeout,
        minimumFetchInterval: _minimumFetchInterval,
      ),
    );
    await _firebaseRemoteConfig.setDefaults(defaultConfigsMap);

    if (_firebaseRemoteConfig.lastFetchStatus ==
        RemoteConfigFetchStatus.noFetchYet) {
      await _firebaseRemoteConfig.fetchAndActivate();
      return;
    }
    await _firebaseRemoteConfig.activate();
    _firebaseRemoteConfig.fetch().ignore();
  }

  RemoteConfigValue getValueForKey(String input) {
    return _firebaseRemoteConfig.getValue(input);
  }

  Map<String, RemoteConfigValue> getAllConfigsValue() {
    return _firebaseRemoteConfig.getAll();
  }
}
