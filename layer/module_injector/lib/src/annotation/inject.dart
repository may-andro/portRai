/// Overrides the resolved type for a constructor parameter during
/// auto-registration.
///
/// By default the generator calls `sl.get<DeclaredType>()` for each
/// constructor parameter.  Use `@Inject(ConcreteType)` when the declared
/// type is abstract but a **specific** concrete registration should be
/// injected instead.
///
/// ### Example
///
/// ```dart
/// @register
/// class AssetExperienceRepositoryImpl implements ExperienceRepository {
///   AssetExperienceRepositoryImpl(
///     this._appLocale,
///     @Inject(CacheExperienceRepositoryImpl) this._cacheDelegateRepository,
///     this._mapper,
///     this._logReporter,
///   );
///
///   final ExperienceRepository _cacheDelegateRepository;
///   // ...
/// }
/// ```
///
/// Generates:
/// ```dart
/// sl.registerFactory<AssetExperienceRepositoryImpl>(
///   () => AssetExperienceRepositoryImpl(
///     sl.get<AppLocale>(),
///     sl.get<CacheExperienceRepositoryImpl>(),   // ← overridden
///     sl.get<ExperienceMapper>(),
///     sl.get<LogReporter>(),
///   ),
/// );
/// ```
class Inject {
  const Inject(this.type);

  /// The concrete type to resolve from the service locator instead of the
  /// declared parameter type.
  final Type type;
}
