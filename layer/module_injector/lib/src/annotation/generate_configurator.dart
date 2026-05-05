/// Marks a [ModuleConfigurator] (or [SimpleModuleConfigurator]) subclass
/// for code generation.
///
/// The generator globs every `.dart` file under the same directory as the
/// annotated configurator and scans them for [Register] or [RegisterSingleton]
/// annotations. It then produces a `$register<Module>Dependencies(ServiceLocator sl)`
/// function containing all factory/singleton registrations.
///
/// ### Example
///
/// ```dart
/// @GenerateConfigurator()
/// class ProfileModuleConfigurator extends SimpleModuleConfigurator {
///   @override
///   void registerDependencies(ServiceLocator sl) => $registerProfileDependencies(sl);
///
///   @override
///   Future<void> postDependenciesSetup(ServiceLocator sl) async {
///     sl.get<ModuleRouteController>().register(ProfileModuleRoute.profile);
///   }
/// }
/// ```
///
/// The generated `$registerProfileDependencies` function will contain all
/// factory/singleton registrations derived from annotated classes.
class GenerateConfigurator {
  const GenerateConfigurator();
}

/// Shorthand for `@GenerateConfigurator()`.
const generateConfigurator = GenerateConfigurator();
