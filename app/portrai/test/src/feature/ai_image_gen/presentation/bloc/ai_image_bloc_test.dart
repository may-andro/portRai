import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/ai_image_gen/domain/_domain.dart';
import 'package:portrai/src/feature/ai_image_gen/presentation/bloc/_bloc.dart';
import 'package:use_case/use_case.dart';

import '../../../../../mock/feature/ai_image_gen/domain/use_case/fake_generate_ai_image_param.dart';
import '../../../../../mock/feature/ai_image_gen/domain/use_case/mock_generate_ai_image_use_case.dart';
import '../../../../../mock/feature/ai_image_gen/domain/use_case/mock_remove_ai_image_background_use_case.dart';

void main() {
  final image = AiImageEntity(
    bytes: Uint8List.fromList([1, 2, 3]),
    mimeType: 'image/png',
  );
  const event = LoadImageEvent(
    sourceImageUrl: 'https://example.com/a.png',
    prompt: 'Draw',
  );

  final transparent = AiImageEntity(
    bytes: Uint8List.fromList([9]),
    mimeType: 'image/png',
  );

  late MockGenerateAiImageUseCase useCase;
  late MockRemoveAiImageBackgroundUseCase removeBackground;

  setUpAll(() {
    registerFallbackValue(FakeGenerateAiImageParam());
    registerFallbackValue(image);
  });

  setUp(() {
    useCase = MockGenerateAiImageUseCase();
    removeBackground = MockRemoveAiImageBackgroundUseCase();
  });

  blocTest<AiImageBloc, AiImageState>(
    'should emit loaded state when the image is generated',
    build: () {
      useCase.stubCall(Right(image));
      return AiImageBloc(useCase, removeBackground);
    },
    act: (bloc) => bloc.add(event),
    expect: () => [LoadedState(image: image)],
    verify: (_) {
      verifyNever(() => removeBackground(any()));
      verify(
        () => useCase(
          const GenerateAiImageParam(
            sourceImageUrl: 'https://example.com/a.png',
            prompt: 'Draw',
          ),
        ),
      ).called(1);
    },
  );

  blocTest<AiImageBloc, AiImageState>(
    'should emit unavailable state when the use case fails',
    build: () {
      useCase.stubCall(const Left(AiImageUnavailableFailure()));
      return AiImageBloc(useCase, removeBackground);
    },
    act: (bloc) => bloc.add(event),
    expect: () => [const UnavailableState()],
  );

  const removeEvent = LoadImageEvent(
    sourceImageUrl: 'https://example.com/a.png',
    prompt: 'Draw',
    removeBackground: true,
  );

  blocTest<AiImageBloc, AiImageState>(
    'should emit the transparent image when background removal is requested',
    build: () {
      useCase.stubCall(Right(image));
      removeBackground.stubCall(Right(transparent));
      return AiImageBloc(useCase, removeBackground);
    },
    act: (bloc) => bloc.add(removeEvent),
    expect: () => [LoadedState(image: transparent)],
  );

  blocTest<AiImageBloc, AiImageState>(
    'should emit the original image when background removal fails',
    build: () {
      useCase.stubCall(Right(image));
      removeBackground.stubCall(const Left(AiImageProcessingFailure()));
      return AiImageBloc(useCase, removeBackground);
    },
    act: (bloc) => bloc.add(removeEvent),
    expect: () => [LoadedState(image: image)],
  );
}
