import 'package:equatable/equatable.dart';

class AssistantAvailabilityEntity extends Equatable {
  const AssistantAvailabilityEntity({
    required this.isFeatureEnabled,
    required this.isSupported,
  });

  const AssistantAvailabilityEntity.unavailable()
    : isFeatureEnabled = false,
      isSupported = false;

  final bool isFeatureEnabled;
  final bool isSupported;

  bool get isAvailable => isFeatureEnabled && isSupported;

  @override
  List<Object?> get props => [isFeatureEnabled, isSupported];
}
