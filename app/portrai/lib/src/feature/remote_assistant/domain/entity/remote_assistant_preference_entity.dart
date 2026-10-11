import 'package:equatable/equatable.dart';

class RemoteAssistantPreferenceEntity extends Equatable {
  const RemoteAssistantPreferenceEntity({
    required this.enabled,
    required this.consentAccepted,
  });

  final bool enabled;
  final bool consentAccepted;

  @override
  List<Object?> get props => [enabled, consentAccepted];
}
