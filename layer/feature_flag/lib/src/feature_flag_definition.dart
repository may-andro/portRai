import 'package:equatable/equatable.dart';

/// Describes a feature flag key that the host app wants this module to
/// evaluate, together with the value to fall back to when the key doesn't
/// exist in the remote source.
///
/// This is intentionally minimal (no display text) - it is the generic
/// seed used to *resolve* a flag's value. Any presentation metadata (name,
/// description, etc.) is a concern of the app embedding this package, not of
/// this module.
class FeatureFlagDefinition extends Equatable {
  const FeatureFlagDefinition({required this.key, required this.defaultValue});

  final String key;
  final bool defaultValue;

  @override
  List<Object?> get props => [key, defaultValue];
}
