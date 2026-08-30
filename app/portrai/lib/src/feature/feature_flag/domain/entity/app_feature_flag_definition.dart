import 'package:equatable/equatable.dart';
import 'package:feature_flag/feature_flag.dart' as layer;

/// Describes a single feature flag owned by an app feature: its identity,
/// default value, and the display text shown on the dev tools screen.
///
/// Each feature that needs a flag declares its own [AppFeatureFlagDefinition]
/// constant(s) in its own domain layer - the `feature_flag` module itself
/// never hardcodes any business flag, it only knows how to evaluate,
/// persist, and list whatever definitions are given to it.
///
/// Unlike the generic [layer.FeatureFlagDefinition] (`key` + `defaultValue`
/// only), this app-layer type also carries [displayName]/[description],
/// which are purely presentational concerns the shared `layer/feature_flag`
/// package doesn't need to know about. Whether a flag ends up backed by
/// Firebase Remote Config or falls back to [defaultValue] is resolved
/// automatically by the layer at runtime - it's not declared here.
class AppFeatureFlagDefinition extends Equatable {
  const AppFeatureFlagDefinition({
    required this.key,
    required this.defaultValue,
    required this.displayName,
    this.description,
  });

  final String key;
  final bool defaultValue;
  final String displayName;
  final String? description;

  /// Converts this into the generic definition the `layer/feature_flag`
  /// package's [layer.FeatureFlagController] resolves against.
  layer.FeatureFlagDefinition get layerDefinition =>
      layer.FeatureFlagDefinition(key: key, defaultValue: defaultValue);

  @override
  List<Object?> get props => [key, defaultValue, displayName, description];
}
