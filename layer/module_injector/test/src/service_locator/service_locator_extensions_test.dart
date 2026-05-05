import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:module_injector/src/service_locator/service_locator.dart';
import 'package:module_injector/src/service_locator/service_locator_extensions.dart';

class _MockServiceLocator implements ServiceLocator {
  final List<String> calls = [];
  final Map<Type, Object> registered = {};

  @override
  T get<T extends Object>() => registered[T]! as T;

  @override
  void registerFactory<T extends Object>(
    T Function() factory, {
    bool shouldOverride = false,
  }) {
    calls.add('registerFactory<$T>');
    registered[T] = factory();
  }

  @override
  void registerSingleton<T extends Object>(
    T Function() factory, {
    FutureOr<void> Function(T param)? dispose,
    bool shouldOverride = false,
  }) {
    calls.add('registerSingleton<$T>');
    registered[T] = factory();
  }

  @override
  bool isRegistered<T extends Object>() => registered.containsKey(T);

  @override
  Future<void> unregister<T extends Object>() async {
    registered.remove(T);
  }

  @override
  Future<void> reset() async {
    registered.clear();
    calls.clear();
  }
}

void main() {
  group('ServiceLocatorX', () {
    late _MockServiceLocator sl;

    setUp(() {
      sl = _MockServiceLocator();
    });

    test('factory delegates to registerFactory', () {
      sl.factory(() => 'hello');
      expect(sl.calls, ['registerFactory<String>']);
      expect(sl.get<String>(), 'hello');
    });

    test('factory with shouldOverride delegates correctly', () {
      sl.factory(() => 'first');
      sl.factory(() => 'second', shouldOverride: true);
      expect(sl.calls.length, 2);
    });

    test('singleton delegates to registerSingleton', () {
      sl.singleton(() => 42);
      expect(sl.calls, ['registerSingleton<int>']);
      expect(sl.get<int>(), 42);
    });

    test('singleton with dispose passes dispose callback', () {
      sl.singleton(() => 'value', dispose: (_) {});
      expect(sl.calls, ['registerSingleton<String>']);
    });

    test('type inference works - registers concrete type from return type', () {
      sl.factory(() => DateTime(2024));
      expect(sl.calls, ['registerFactory<DateTime>']);
    });

    test('explicit type parameter registers abstract type', () {
      sl.factory<num>(() => 3.14);
      expect(sl.calls, ['registerFactory<num>']);
    });
  });
}
