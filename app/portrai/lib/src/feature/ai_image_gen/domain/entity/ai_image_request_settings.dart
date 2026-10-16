import 'package:equatable/equatable.dart';

/// The prompt text and model id that a generation request is made with.
class AiImageRequestSettings extends Equatable {
  const AiImageRequestSettings({required this.prompt, required this.model});

  final String prompt;
  final String model;

  @override
  List<Object> get props => [prompt, model];
}
