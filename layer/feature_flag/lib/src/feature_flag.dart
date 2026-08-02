import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'feature_flag.g.dart';

@JsonSerializable()
class FeatureFlag extends Equatable {
  const FeatureFlag({
    required this.key,
    required this.isEnabled,
    this.isOverridden = false,
    this.remoteValue,
  });

  factory FeatureFlag.fromJson(Map<String, dynamic> json) =>
      _$FeatureFlagFromJson(json);

  @JsonKey(name: 'key')
  final String key;

  @JsonKey(name: 'is_enabled')
  final bool isEnabled;

  /// Whether this flag's value has been manually overridden by a developer
  ///
  /// Only applicable in staging builds when [BuildEnvironment.isFeatureFlagCached] is true
  @JsonKey(name: 'is_overridden')
  final bool isOverridden;

  /// The original remote value before any override was applied
  ///
  /// This is null if the flag was never overridden or if the remote value is unknown
  @JsonKey(name: 'remote_value')
  final bool? remoteValue;

  Map<String, dynamic> toJson() => _$FeatureFlagToJson(this);

  FeatureFlag copyWith({
    String? key,
    bool? isEnabled,
    bool? isOverridden,
    bool? remoteValue,
  }) {
    return FeatureFlag(
      key: key ?? this.key,
      isEnabled: isEnabled ?? this.isEnabled,
      isOverridden: isOverridden ?? this.isOverridden,
      remoteValue: remoteValue ?? this.remoteValue,
    );
  }

  @override
  List<Object?> get props => [key, isEnabled, isOverridden, remoteValue];
}
