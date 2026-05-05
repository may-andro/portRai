import 'dart:async';
import 'dart:convert';

import 'package:cache/src/adapter/key_value_adapter.dart';
import 'package:cache/src/adapter/shared_preferences_key_value_adapter.dart';
import 'package:cache/src/cache.dart';
import 'package:meta/meta.dart';

/// Abstract base class for key-value–backed caches.
///
/// Extend this class and implement the required members to make any object
/// cacheable using the underlying key-value storage.
///
/// [SharedPreferencesKeyValueAdapter] is used as the underlying storage engine
/// by default; the [adapter] parameter exists only for injecting a test double
/// inside the `cache` package's own tests.
///
/// ### Example
/// ```dart
/// class UserPreferencesCache extends KeyValueCache<UserPreferences> {
///   UserPreferencesCache() : super('user_preferences');
///
///   @override
///   UserPreferences deserializeValue(Map<String, dynamic> map) =>
///       UserPreferences.fromJson(map);
///
///   @override
///   Map<String, dynamic> serializeValue(UserPreferences value) =>
///       value.toJson();
/// }
/// ```
abstract class KeyValueCache<T> extends Cache {
  KeyValueCache(this._cacheKey, {@visibleForTesting KeyValueAdapter? adapter})
    : _adapter = adapter ?? SharedPreferencesKeyValueAdapter();

  final KeyValueAdapter _adapter;
  final String _cacheKey;

  // Caches the initialization future so concurrent callers await the same
  // operation instead of each starting their own.
  Future<void>? _initFuture;

  final _controller = StreamController<T?>.broadcast();

  T deserializeValue(Map<String, dynamic> map);

  Map<String, dynamic> serializeValue(T value);

  @override
  int get lastCachedTimestamp => _adapter.getInt(_expirationKey) ?? 0;

  Future<T?> get() async {
    await _ensureInitialized();
    final value = _adapter.getString(_cacheKey);
    if (value == null) return null;
    if (isExpired) {
      await delete();
      return null;
    }
    return deserializeValue(jsonDecode(value) as Map<String, dynamic>);
  }

  Future<bool> put(T value) async {
    await _ensureInitialized();
    await _adapter.setInt(
      _expirationKey,
      DateTime.now().millisecondsSinceEpoch,
    );
    final result = await _adapter.setString(
      _cacheKey,
      jsonEncode(serializeValue(value)),
    );
    _controller.add(value);
    return result;
  }

  Future<bool> delete() async {
    await _ensureInitialized();
    await _adapter.remove(_expirationKey);
    final result = await _adapter.remove(_cacheKey);
    _controller.add(null);
    return result;
  }

  /// Returns a broadcast stream that emits the current value after every
  /// [put] call and `null` after every [delete] call.
  ///
  /// The stream is broadcast, so multiple listeners are supported.
  Stream<T?> watch() => _controller.stream;

  String get _expirationKey => '$_cacheKey.expiration';

  // Returns the single shared initialization future, starting it on first
  // call. If initialization fails the future is cleared so the next call
  // retries.
  Future<void> _ensureInitialized() => _initFuture ??= _initialize();

  Future<void> _initialize() async {
    try {
      await _adapter.initialize();
    } catch (e) {
      _initFuture = null; // allow retry on next call
      rethrow;
    }
  }
}
