import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
sealed class AiImageEvent extends Equatable {
  const AiImageEvent();

  @override
  List<Object?> get props => [];
}

final class LoadImageEvent extends AiImageEvent {
  const LoadImageEvent({
    required this.sourceImageUrl,
    required this.prompt,
    this.removeBackground = false,
  });

  final String sourceImageUrl;
  final String prompt;
  final bool removeBackground;

  @override
  List<Object?> get props => [sourceImageUrl, prompt, removeBackground];
}
