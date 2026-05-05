import 'dart:async';

import 'package:cache/src/cache.dart';

/// A simple in-memory cache that stores a single value of type [T].
///
/// Data lives only in the current isolate's heap and is lost when the process
/// exits. Use this for short-lived, ephemeral values that don't need
/// persistence (e.g. an API response that should be kept for a few minutes).
///
/// ### Example
/// ```dart
/// class UserMemoryCache extends MemoryCache<User> {
///   @override
///   Duration get timeToLive => const Duration(minutes: 5);
/// }
/// ```
class MemoryCache<T> extends Cache {
  T? _model;
  int? _cachedTimestamp;

  final _controller = StreamController<T?>.broadcast();

  /// Returns the cached value, or `null` if no value is set or the entry has
  /// expired.
  ///
  /// Expired entries are automatically deleted.
  T? get() {
    if (_model == null) return null;
    if (isExpired) {
      delete();
      return null;
    }
    return _model;
  }

  /// Stores [model] in the cache and records the current timestamp for TTL
  /// checks.
  void put(T model) {
    _model = model;
    _cachedTimestamp = DateTime.now().millisecondsSinceEpoch;
    _controller.add(model);
  }

  /// Removes the cached value and its timestamp.
  void delete() {
    _model = null;
    _cachedTimestamp = null;
    _controller.add(null);
  }

  /// Returns a broadcast stream that emits the current value after every
  /// [put] call and `null` after every [delete] call.
  ///
  /// The stream is broadcast, so multiple listeners are supported.
  Stream<T?> watch() => _controller.stream;

  @override
  int get lastCachedTimestamp => _cachedTimestamp ?? 0;
}
