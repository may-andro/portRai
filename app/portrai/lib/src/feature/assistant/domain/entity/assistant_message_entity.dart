import 'package:equatable/equatable.dart';
import 'package:portrai/src/feature/assistant/domain/entity/assistant_response_entity.dart';

class AssistantMessageEntity extends Equatable {
  const AssistantMessageEntity({required this.content, required this.isUser});

  final AssistantResponseEntity content;
  final bool isUser;

  @override
  List<Object?> get props => [content, isUser];
}
