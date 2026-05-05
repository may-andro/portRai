import 'dart:convert';

import 'package:cache/src/adapter/key_value_adapter.dart';
import 'package:cache/src/key_value_cache.dart';
import 'package:flutter_test/flutter_test.dart';

/// Simple in-memory [KeyValueAdapter] for testing.
class _InMemoryKeyValueAdapter implements KeyValueAdapter {
  final Map<String, String> _strings = {};
  final Map<String, int> _ints = {};

  @override
  Future<void> initialize() async {}

  @override
  String? getString(String key) => _strings[key];

  @override
  Future<bool> setString(String key, String value) async {
    _strings[key] = value;
    return true;
  }

  @override
  int? getInt(String key) => _ints[key];

  @override
  Future<bool> setInt(String key, int value) async {
    _ints[key] = value;
    return true;
  }

  @override
  Future<bool> remove(String key) async {
    _strings.remove(key);
    _ints.remove(key);
    return true;
  }
}

class _TestCache extends KeyValueCache<String> {
  _TestCache({super.adapter}) : super('test_cache');

  @override
  String deserializeValue(Map<String, dynamic> map) {
    return map['name'] as String;
  }

  @override
  Map<String, dynamic> serializeValue(String value) {
    return {'name': value};
  }

  @override
  Duration get timeToLive => const Duration(milliseconds: 300);
}

void main() {
  group(KeyValueCache, () {
    late KeyValueCache<String> keyValueCache;
    late _InMemoryKeyValueAdapter adapter;

    setUp(() {
      adapter = _InMemoryKeyValueAdapter();
      keyValueCache = _TestCache(adapter: adapter);
    });

    group('get', () {
      test('should return null when cache does not exist', () async {
        final result = await keyValueCache.get();
        expect(result, isNull);
      });

      test('should return null when cache is expired', () async {
        // Manually set a value with an old timestamp so it's expired.
        adapter._strings['test_cache'] =
            jsonEncode(keyValueCache.serializeValue('test'));
        // Don't set expiration timestamp → defaults to 0 → expired.

        final result = await keyValueCache.get();
        expect(result, isNull);
        // Verify the expired entries were cleaned up.
        expect(adapter._strings.containsKey('test_cache'), isFalse);
      });

      test('should return value when unexpired', () async {
        await keyValueCache.put('test');
        final result = await keyValueCache.get();
        expect(result, equals('test'));
      });
    });

    group('put', () {
      test('should set the entry and expiration', () async {
        await keyValueCache.put('Test');

        expect(adapter._strings['test_cache'], isNotNull);
        expect(adapter._ints['test_cache.expiration'], isNotNull);
      });
    });

    group('delete', () {
      test('should delete the entry and expiration', () async {
        await keyValueCache.put('Test');
        await keyValueCache.delete();

        expect(adapter._strings.containsKey('test_cache'), isFalse);
        expect(adapter._ints.containsKey('test_cache.expiration'), isFalse);
      });
    });

    group('watch', () {
      test('should emit value on put', () async {
        final future = keyValueCache.watch().first;
        await keyValueCache.put('hello');
        expect(await future, equals('hello'));
      });

      test('should emit null on delete', () async {
        await keyValueCache.put('hello');
        final future = keyValueCache.watch().first;
        await keyValueCache.delete();
        expect(await future, isNull);
      });

      test('should emit consecutive values', () async {
        final values = <String?>[];
        final sub = keyValueCache.watch().listen(values.add);

        await keyValueCache.put('a');
        await keyValueCache.put('b');
        await keyValueCache.delete();

        // Allow microtasks to flush.
        await Future<void>.delayed(Duration.zero);

        expect(values, equals(['a', 'b', null]));
        await sub.cancel();
      });

      test('should support multiple listeners', () async {
        final values1 = <String?>[];
        final values2 = <String?>[];
        final sub1 = keyValueCache.watch().listen(values1.add);
        final sub2 = keyValueCache.watch().listen(values2.add);

        await keyValueCache.put('x');

        await Future<void>.delayed(Duration.zero);

        expect(values1, equals(['x']));
        expect(values2, equals(['x']));
        await sub1.cancel();
        await sub2.cancel();
      });
    });
  });
}
