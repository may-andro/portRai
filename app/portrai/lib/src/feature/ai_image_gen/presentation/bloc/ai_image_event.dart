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
    this.removeBackground = false,
  });

  final String sourceImageUrl;
  final bool removeBackground;

  @override
  List<Object?> get props => [sourceImageUrl, removeBackground];
}
