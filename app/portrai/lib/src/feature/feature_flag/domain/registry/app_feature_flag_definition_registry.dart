import 'package:log_reporter/log_reporter.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/feature_flag/domain/entity/_entity.dart';

/// Aggregates every [AppFeatureFlagDefinition] contributed by the app's
/// features.
///
/// Each feature that owns a flag registers its own [AppFeatureFlagDefinition]
/// here from its own module configurator's `postDependenciesSetup`
/// (mirroring how [ModuleRouteController] aggregates routes), so the
/// `feature_flag` module never needs to know about any business feature
/// itself. Only consumed by the dev tools "list all flags" screen, which is
/// opened well after every module has finished registering - so the
/// registration order between configurators does not matter here.
@registerSingleton
class AppFeatureFlagDefinitionRegistry {
  AppFeatureFlagDefinitionRegistry(this._logReporter);

  final LogReporter _logReporter;

  final List<AppFeatureFlagDefinition> _definitions = [];

  void register(AppFeatureFlagDefinition definition) {
    if (_definitions.any((d) => d.key == definition.key)) {
      _logReporter.error(
        'Duplicate AppFeatureFlagDefinition found for key "${definition.key}"',
        stacktrace: StackTrace.current,
        error: _AppFeatureFlagDefinitionRegisteredException(definition.key),
        tag: 'AppFeatureFlagDefinitionRegistry',
      );
      return;
    }
    _definitions.add(definition);
  }

  /// Returns every [AppFeatureFlagDefinition] registered by any feature.
  List<AppFeatureFlagDefinition> get all => List.unmodifiable(_definitions);
}

class _AppFeatureFlagDefinitionRegisteredException implements Exception {
  const _AppFeatureFlagDefinitionRegisteredException(this.key);

  final String key;

  @override
  String toString() {
    return '_AppFeatureFlagDefinitionRegisteredException: '
        'The AppFeatureFlagDefinition for key "$key" is already registered';
  }
}
