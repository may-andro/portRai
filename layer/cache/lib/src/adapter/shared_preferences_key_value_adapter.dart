import 'package:cache/src/adapter/key_value_adapter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A [KeyValueAdapter] backed by [SharedPreferences].
///
/// This is the default adapter used by [KeyValueCache]. It is internal to the
/// cache module and not exported from the barrel file.
class SharedPreferencesKeyValueAdapter implements KeyValueAdapter {
  SharedPreferencesKeyValueAdapter();

  SharedPreferences? _prefs;

  @override
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  @override
  String? getString(String key) => _requirePrefs().getString(key);

  @override
  Future<bool> setString(String key, String value) =>
      _requirePrefs().setString(key, value);

  @override
  int? getInt(String key) => _requirePrefs().getInt(key);

  @override
  Future<bool> setInt(String key, int value) =>
      _requirePrefs().setInt(key, value);

  @override
  Future<bool> remove(String key) => _requirePrefs().remove(key);

  SharedPreferences _requirePrefs() {
    final prefs = _prefs;
    if (prefs == null) {
      throw StateError(
        'SharedPreferencesKeyValueAdapter has not been initialized. '
        'Call initialize() first.',
      );
    }
    return prefs;
  }
}
