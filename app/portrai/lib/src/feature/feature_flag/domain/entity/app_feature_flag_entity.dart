import 'package:equatable/equatable.dart';
import 'package:portrai/src/feature/feature_flag/domain/entity/app_feature_flag.dart';

class AppFeatureFlagEntity extends Equatable {
  const AppFeatureFlagEntity({
    required this.flag,
    required this.isEnabled,
    required this.isOverridden,
    this.remoteValue,
    this.displayName,
    this.description,
  });

  final AppFeatureFlag flag;
  final bool isEnabled;
  final bool isOverridden;
  final bool? remoteValue;
  final String? displayName;
  final String? description;

  String get key => flag.key;

  @override
  List<Object?> get props => [
    flag,
    isEnabled,
    isOverridden,
    remoteValue,
    displayName,
    description,
  ];

  String get name => displayName ?? _formatKey(flag.name);

  bool get isModified => isOverridden && remoteValue != null;

  String get statusDescription {
    if (!isOverridden) {
      return isEnabled ? 'Enabled (Remote)' : 'Disabled (Remote)';
    }
    return isEnabled ? 'Enabled (Override)' : 'Disabled (Override)';
  }

  String _formatKey(String key) {
    return key
        .split(RegExp(r'(?=[A-Z])'))
        .map(
          (word) => word.isEmpty
              ? ''
              : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  AppFeatureFlagEntity copyWith({
    AppFeatureFlag? flag,
    bool? isEnabled,
    bool? isOverridden,
    bool? remoteValue,
    String? displayName,
    String? description,
  }) {
    return AppFeatureFlagEntity(
      flag: flag ?? this.flag,
      isEnabled: isEnabled ?? this.isEnabled,
      isOverridden: isOverridden ?? this.isOverridden,
      remoteValue: remoteValue ?? this.remoteValue,
      displayName: displayName ?? this.displayName,
      description: description ?? this.description,
    );
  }
}
