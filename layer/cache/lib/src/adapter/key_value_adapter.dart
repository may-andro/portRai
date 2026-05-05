/// Abstract interface for the persistence layer used by [KeyValueCache].
///
/// Implement this interface to swap the underlying key-value storage technology
/// without touching the cache or domain layers.
///
/// A concrete [KeyValueAdapter] is responsible for:
///  - Initializing the storage backend on [initialize].
///  - Translating the generic get/set/remove calls into the native API of the
///    chosen storage engine.
///
/// Example engines: SharedPreferences, Hive, in-memory (for tests).
abstract class KeyValueAdapter {
  /// Opens and prepares the underlying storage.
  ///
  /// Must be called once before any other method.
  Future<void> initialize();

  /// Returns the string value for [key], or `null` if not present.
  String? getString(String key);

  /// Stores a string [value] under [key].
  Future<bool> setString(String key, String value);

  /// Returns the integer value for [key], or `null` if not present.
  int? getInt(String key);

  /// Stores an integer [value] under [key].
  Future<bool> setInt(String key, int value);

  /// Removes the entry for [key].
  Future<bool> remove(String key);
}
