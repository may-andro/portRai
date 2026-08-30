import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'feature_flag.g.dart';

@JsonSerializable()
class FeatureFlag extends Equatable {
  const FeatureFlag({
    required this.key,
    required this.isEnabled,
    this.isOverridden = false,
    this.hasRemoteSource = false,
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

  /// Whether this flag's key currently exists in the remote source.
  ///
  /// `false` means the key wasn't found remotely, so [isEnabled] falls back
  /// to the [FeatureFlagDefinition.defaultValue] the flag was resolved with
  /// (persisted locally so it survives across app restarts).
  @JsonKey(name: 'has_remote_source')
  final bool hasRemoteSource;

  /// The last known remote value, kept for reverting an override.
  ///
  /// Always `null` when [hasRemoteSource] is `false`.
  @JsonKey(name: 'remote_value')
  final bool? remoteValue;

  Map<String, dynamic> toJson() => _$FeatureFlagToJson(this);

  FeatureFlag copyWith({
    String? key,
    bool? isEnabled,
    bool? isOverridden,
    bool? hasRemoteSource,
    bool? remoteValue,
  }) {
    return FeatureFlag(
      key: key ?? this.key,
      isEnabled: isEnabled ?? this.isEnabled,
      isOverridden: isOverridden ?? this.isOverridden,
      hasRemoteSource: hasRemoteSource ?? this.hasRemoteSource,
      remoteValue: remoteValue ?? this.remoteValue,
    );
  }

  @override
  List<Object?> get props => [
    key,
    isEnabled,
    isOverridden,
    hasRemoteSource,
    remoteValue,
  ];
}
