import 'package:equatable/equatable.dart';

/// Content supported by the app, independent of the inference provider.
sealed class AssistantResponseEntity extends Equatable {
  const AssistantResponseEntity();
}

final class AssistantTextResponseEntity extends AssistantResponseEntity {
  const AssistantTextResponseEntity({required this.text});

  final String text;

  @override
  List<Object?> get props => [text];
}
