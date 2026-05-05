/// Marks a class for automatic lazy singleton registration with [ServiceLocator].
///
/// Similar to [Register], but uses `sl.registerSingleton` instead of
/// `sl.registerFactory`.
///
/// ### Example
///
/// ```dart
/// @registerSingleton
/// class AppConfig {
///   AppConfig(this._environment);
///   final BuildEnvironment _environment;
/// }
/// ```
///
/// Use [as] to register under an abstract type:
/// ```dart
/// @RegisterSingleton(as: Cache)
/// class InMemoryCache implements Cache { ... }
/// ```
///
/// Use [shouldOverride] to allow replacing an existing singleton registration:
/// ```dart
/// @RegisterSingleton(shouldOverride: true)
/// class TestAppConfig extends AppConfig { ... }
/// ```
///
/// Use [disposeMethodName] to generate a `dispose:` callback that calls the
/// named method on the singleton instance when it is unregistered:
/// ```dart
/// @RegisterSingleton(disposeMethodName: 'close')
/// class DatabaseConnection { void close() { ... } }
/// ```
/// Generates:
/// ```dart
/// sl.registerSingleton<DatabaseConnection>(
///   () => DatabaseConnection(),
///   dispose: (it) => it.close(),
/// );
/// ```
class RegisterSingleton {
  const RegisterSingleton({
    this.as,
    this.shouldOverride = false,
    this.disposeMethodName,
  });

  /// When provided, register this class under the given abstract type.
  final Type? as;

  /// When `true`, generates `shouldOverride: true` in the registration call.
  final bool shouldOverride;

  /// When provided, generates a `dispose: (it) => it.<disposeMethodName>()` callback.
  final String? disposeMethodName;
}

/// Shorthand for `@RegisterSingleton()` — registers as a lazy singleton under its own type.
const registerSingleton = RegisterSingleton();
