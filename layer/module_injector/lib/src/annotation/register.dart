/// Marks a class for automatic factory registration with [ServiceLocator].
///
/// The generator will produce a `sl.registerFactory<T>(() => T(sl.get(), ...))` call
/// by reading the class's constructor parameters.
///
/// ### Example
///
/// ```dart
/// @register
/// class GetProfileUseCase {
///   GetProfileUseCase(this._repository);
///   final ProfileRepository _repository;
/// }
/// ```
///
/// Generates:
/// ```dart
/// sl.registerFactory<GetProfileUseCase>(
///   () => GetProfileUseCase(sl.get<ProfileRepository>()),
/// );
/// ```
///
/// Use [as] to register under an abstract type:
/// ```dart
/// @Register(as: ProfileRepository)
/// class RemoteProfileRepository implements ProfileRepository { ... }
/// ```
///
/// Use [shouldOverride] to allow overwriting an existing registration (useful
/// in tests or multi-module setups where a binding may be replaced):
/// ```dart
/// @Register(as: ProfileRepository, shouldOverride: true)
/// class FakeProfileRepository implements ProfileRepository { ... }
/// ```
class Register {
  const Register({this.as, this.shouldOverride = false});

  /// When provided, register this class under the given abstract type.
  ///
  /// For example, `@Register(as: ProfileRepository)` will generate:
  /// ```dart
  /// sl.registerFactory<ProfileRepository>(() => RemoteProfileRepository(...));
  /// ```
  final Type? as;

  /// When `true`, generates `shouldOverride: true` in the registration call,
  /// allowing this registration to replace an existing one.
  final bool shouldOverride;
}

/// Shorthand for `@Register()` — registers the class as a factory under its own type.
const register = Register();
