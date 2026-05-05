import 'dart:async';

import 'package:module_injector/src/service_locator/service_locator.dart';

/// Shorthand registration methods for [ServiceLocator].
///
/// Reduces verbose registration calls from:
/// ```dart
/// serviceLocator.registerFactory<ProfileRepository>(
///   () => ProfileRepository(
///     serviceLocator.get<ProfileCache>(),
///     serviceLocator.get<ProfileMapper>(),
///   ),
/// );
/// ```
///
/// To:
/// ```dart
/// sl.factory(() => ProfileRepository(sl.get(), sl.get()));
/// ```
///
/// The generic type is inferred from the factory return type. Use an explicit
/// type parameter when registering an abstract type:
/// ```dart
/// sl.factory<ProfileRepository>(
///   () => RemoteProfileRepository(sl.get(), sl.get()),
/// );
/// ```
extension ServiceLocatorX on ServiceLocator {
  /// Shorthand for [registerFactory].
  void factory<T extends Object>(
    T Function() create, {
    bool shouldOverride = false,
  }) => registerFactory<T>(create, shouldOverride: shouldOverride);

  /// Shorthand for [registerSingleton].
  void singleton<T extends Object>(
    T Function() create, {
    FutureOr<void> Function(T)? dispose,
    bool shouldOverride = false,
  }) => registerSingleton<T>(
    create,
    dispose: dispose,
    shouldOverride: shouldOverride,
  );
}
