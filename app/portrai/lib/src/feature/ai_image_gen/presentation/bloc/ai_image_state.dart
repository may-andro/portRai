import 'package:equatable/equatable.dart';
import 'package:portrai/src/feature/ai_image_gen/domain/entity/_entity.dart';

sealed class AiImageState extends Equatable {
  const AiImageState();

  @override
  List<Object?> get props => [];
}

final class LoadingState extends AiImageState {
  const LoadingState();
}

final class LoadedState extends AiImageState {
  const LoadedState({required this.image});

  final AiImageEntity image;

  @override
  List<Object?> get props => [image];
}

final class UnavailableState extends AiImageState {
  const UnavailableState();
}
