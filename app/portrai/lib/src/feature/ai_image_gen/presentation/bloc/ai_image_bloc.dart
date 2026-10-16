import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/ai_image_gen/domain/use_case/_use_case.dart';
import 'package:portrai/src/feature/ai_image_gen/presentation/bloc/ai_image_event.dart';
import 'package:portrai/src/feature/ai_image_gen/presentation/bloc/ai_image_state.dart';

@register
class AiImageBloc extends Bloc<AiImageEvent, AiImageState> {
  AiImageBloc(this._generateAiImageUseCase, this._removeBackgroundUseCase)
    : super(const LoadingState()) {
    on<LoadImageEvent>(_mapLoadImageEventToState);
  }

  final GenerateAiImageUseCase _generateAiImageUseCase;
  final RemoveAiImageBackgroundUseCase _removeBackgroundUseCase;

  FutureOr<void> _mapLoadImageEventToState(
    LoadImageEvent event,
    Emitter<AiImageState> emit,
  ) async {
    final result = await _generateAiImageUseCase(
      GenerateAiImageParam(sourceImageUrl: event.sourceImageUrl),
    );
    final generated = result.fold((_) => null, (image) => image);
    if (generated == null) {
      emit(const UnavailableState());
      return;
    }
    if (!event.removeBackground) {
      emit(LoadedState(image: generated));
      return;
    }
    final processed = await _removeBackgroundUseCase(generated);
    // An opaque image is better than no image when processing fails.
    emit(
      LoadedState(image: processed.fold((_) => generated, (image) => image)),
    );
  }
}
