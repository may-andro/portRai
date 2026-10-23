import 'package:cache/src/memory_cache.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestMemoryCache extends MemoryCache<String> {
  @override
  Duration get timeToLive => const Duration(milliseconds: 300);
}

void main() {
  group(MemoryCache, () {
    late MemoryCache<String> memoryCache;

    setUp(() {
      memoryCache = _TestMemoryCache();
    });

    group('get', () {
      test('should return null by when no value is set', () {
        final result = memoryCache.get();
        expect(result, isNull);
      });

      test('should return null value when expired', () async {
        memoryCache.put('Test');
        await Future<dynamic>.delayed(const Duration(milliseconds: 301));
        final result = memoryCache.get();
        expect(result, isNull);
      });

      test('should return value when unexpired', () {
        memoryCache.put('Test');
        final result = memoryCache.get();
        expect(result, isNotNull);
      });
    });

    group('put', () {
      test('should cache the value', () {
        memoryCache.put('Test');
        expect(memoryCache.get(), 'Test');
      });
    });

    group('delete', () {
      test('should delete the value', () {
        memoryCache.delete();
        expect(memoryCache.get(), isNull);
      });
    });

    group('watch', () {
      test('should emit value on put', () async {
        final future = memoryCache.watch().first;
        memoryCache.put('hello');
        expect(await future, equals('hello'));
      });

      test('should emit null on delete', () async {
        memoryCache.put('hello');
        final future = memoryCache.watch().first;
        memoryCache.delete();
        expect(await future, isNull);
      });

      test('should emit consecutive values', () async {
        final values = <String?>[];
        final sub = memoryCache.watch().listen(values.add);

        memoryCache.put('a');
        memoryCache.put('b');
        memoryCache.delete();

        // Allow microtasks to flush.
        await Future<void>.delayed(Duration.zero);

        expect(values, equals(['a', 'b', null]));
        await sub.cancel();
      });

      test('should support multiple listeners', () async {
        final values1 = <String?>[];
        final values2 = <String?>[];
        final sub1 = memoryCache.watch().listen(values1.add);
        final sub2 = memoryCache.watch().listen(values2.add);

        memoryCache.put('x');

        await Future<void>.delayed(Duration.zero);

        expect(values1, equals(['x']));
        expect(values2, equals(['x']));
        await sub1.cancel();
        await sub2.cancel();
      });
    });
  });
}
