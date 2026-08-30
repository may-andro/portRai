import 'package:equatable/equatable.dart';
import 'package:portrai/src/feature/feature_flag/domain/entity/app_feature_flag_definition.dart';

class AppFeatureFlagEntity extends Equatable {
  const AppFeatureFlagEntity({
    required this.flag,
    required this.isEnabled,
    required this.isOverridden,
    this.hasRemoteSource = false,
    this.remoteValue,
  });

  final AppFeatureFlagDefinition flag;
  final bool isEnabled;
  final bool isOverridden;
  final bool hasRemoteSource;
  final bool? remoteValue;

  String get key => flag.key;

  @override
  List<Object?> get props => [
    flag,
    isEnabled,
    isOverridden,
    hasRemoteSource,
    remoteValue,
  ];

  String get name => flag.displayName;

  String? get description => flag.description;

  bool get isModified => isOverridden && remoteValue != null;

  String get statusDescription {
    if (isOverridden) {
      return isEnabled ? 'Enabled (Override)' : 'Disabled (Override)';
    }
    if (hasRemoteSource) {
      return isEnabled ? 'Enabled (Remote)' : 'Disabled (Remote)';
    }
    return isEnabled ? 'Enabled (Local)' : 'Disabled (Local)';
  }

  AppFeatureFlagEntity copyWith({
    AppFeatureFlagDefinition? flag,
    bool? isEnabled,
    bool? isOverridden,
    bool? hasRemoteSource,
    bool? remoteValue,
  }) {
    return AppFeatureFlagEntity(
      flag: flag ?? this.flag,
      isEnabled: isEnabled ?? this.isEnabled,
      isOverridden: isOverridden ?? this.isOverridden,
      hasRemoteSource: hasRemoteSource ?? this.hasRemoteSource,
      remoteValue: remoteValue ?? this.remoteValue,
    );
  }
}
